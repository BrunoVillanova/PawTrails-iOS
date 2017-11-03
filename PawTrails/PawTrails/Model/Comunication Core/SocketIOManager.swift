//
//  SocketIOManagement.swift
//  PawTrails
//
//  Created by Marc Perello on 03/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//
import Foundation
import UIKit
import SocketIO
import SwiftyJSON
import RxSwift

/// Performs communication with Socket IO Platform
class SocketIOManager: NSObject, URLSessionDelegate {
    
    /// Shared Instance
    static let instance = SocketIOManager()
    
    private let urlString = "http://eu.pawtrails.pet:2003"
    private let urlStringSSL = "https://eu.pawtrails.pet:4654"
    

    
    private var socket: SocketIOClient!
    private let disposeBag = DisposeBag()
    public var socketReactive: Reactive<SocketIOClient>?
    
    private var onUpdates = [Int:Bool]()
    private var PetsGPSData = NSCache<NSNumber,GPSData>()
    
    public var isConnected = false
    private var isConnecting = false
    private var isAuthenticating = false
    
    init(SSLEnabled: Bool = true) {
        super.init()
        
        let urlString = SSLEnabled ? self.urlStringSSL : self.urlString
        
        if let url = URL(string: urlString) {
            self.socket = SocketIOClient(socketURL: url, config: [.log(false), .secure(true)])
        }
        
        // Init SocketIO
        socketReactive = Reactive<SocketIOClient>(socket)
        
        // Define SocketIO event handlers
        socketReactive?.on("connect").subscribe(onNext: { (data) in
            self.isConnected = true
            self.isConnecting = false
            self.socketAuth()
        }){}.disposed(by: disposeBag)
        
        socketReactive?.on("authCheck").subscribe(onNext: { (data) in
            self.isAuthenticating = false
            let status = self.getStatus(data)
            if (status == .connected) {
                DataManager.instance.loadPets { (error, pets) in
                    if error == nil, let pets = pets {
                        let petIDs = pets.map { $0.id }
                        self.socket.emit("gpsPets", ["ids": petIDs, "noLastPos": false])
                        NotificationManager.instance.postPetListUpdates(with: pets)
                    }
                }
            } else if (status == .unauthorized || status == .unauthorized2) {
                //TODO: force user to login again
            } else if (status != .waiting) {
                self.socketAuth()
            }
        }){}.disposed(by: disposeBag)
        
        for key in self.onUpdates.keys {  self.onUpdates[key] = false }
    }
    
    func gpsUpdates() -> Observable<[Any]>? {
        if !self.isConnected {
            self.connect()
        }
        
        return socketReactive?.on("gpsUpdates");
    }
    
    
    func socketAuth() {
        guard !isAuthenticating && isConnected else {
            return
        }
        
        let token = SharedPreferences.get(.token)
        if token != "" {
            Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "Connecting")
            isAuthenticating = true
            socket.emit("authCheck", token)
        } else{
            Reporter.send(file: "\(#file)", function: "\(#function)", NSError(domain: "Socket IO", code: -1, userInfo: ["reason": "missing token"]))
        }
    }
    
    /// Establishes Connection with Socket IO, peforms login driven by token.
    ///
    /// - Parameter callback: returns socket IO connection status
    func connect(_ callback: ((SocketIOStatus)->())? = nil) {
        
        guard !self.isConnecting else {
            return
        }
        
        if DataManager.instance.isAuthenticated() {
            self.isConnecting = true
            socket.connect()
        }

//        self.socket.on("connect") { (data, ack) in
//            let token = SharedPreferences.get(.token)
//            if token != "" {
//                Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "Connecting")
//                self.socket.emit("authCheck", token)
//            } else{
//                Reporter.send(file: "\(#file)", function: "\(#function)", NSError(domain: "Socket IO", code: -1, userInfo: ["reason": "missing token"]))
//            }
//        }
//
//        self.socket.on("authCheck") { (data, ack) in
//            let status = self.getStatus(data)
//            self.isConnected = (status == .connected)
//
//            Reporter.debugPrint(file: "\(#file)", function: "\(#function)", status)
//
//            guard callback != nil else {
//                return
//            }
//            callback!(status)
//        }
//
//        self.socket.on("disconnect") { (_, _) in
//            self.isConnected = false
//        }
//
//        self.socket.connect()
    }
    
    /// Disconnects from Socket I.O.
    func disconnect() {
        self.socket.disconnect()
        self.isConnected = false
    }
    
    
    func startGettingGpsUpdates(for petId: [Int]) {
        if (self.isConnected) {
            self.socket.emit("gpsPets", ["ids": petId, "noLastPos": false])
            self.socket.on("gpsUpdates") { (data, Ack) in
                print("Received Pet GPS Updates")
                for deviceData in data {
                    print(deviceData)
                }
            }
        } else {
            self.connect({ (status) in
                if (status == .connected) {
                    self.startGettingGpsUpdates(for: petId)
                }
            })
        }

    }

    
    // MARK: establish connection with PetsList channel.
    func connectToPetChannel() {
        self.socket.emit("getPetList", false)
        self.socket.on("pets", callback: { (data, ack) in
            print("Here is my data\(data)")
        })
    }

    //MARK:- Pet
    /// Collect GPS Data for pet id
    ///
    /// - Parameter id: pet id
    /// - Returns: returns GPSData if available else *nil*
    func getGPSData(for id: Int) -> GPSData? {
        return PetsGPSData.object(forKey: NSNumber(integerLiteral: Int(id)))
    }
    
    /// Set Location Name
    ///
    /// - Parameters:
    ///   - locationName: location name
    ///   - petId: pet id
    func set(_ locationName: String, for petId: Int){
        if let data = getGPSData(for: petId) {
            data.locationAndTime = "\(locationName) - \(data.distanceTime)"
        }
    }
    
    /// Start pets GPS Updates
    ///
    //    /// - Parameter petIds: pet ids
    func startGPSUpdates(for petIds: [Int]){
        for petId in petIds {
            self.startGPSUpdatesEffective(for: petId)
        }
    }
    
    private func startGPSUpdatesEffective(for petId: Int) {
        if onUpdates[petId] == nil || (onUpdates[petId] != nil && onUpdates[petId] == false) {
            Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "Start Updates for pet: ", petId)
            
            if PetsGPSData.object(forKey: NSNumber(value: petId)) == nil {
                let data = GPSData()
                data.status = .disconected
                PetsGPSData.setObject(data, forKey: NSNumber(value: petId))
            }
            
          self.socket.on("gpsUpdates", callback: { (data, ack) in
              Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "gpsData Update response", data)
                self.handleGPSUpdates(data)
          
          })
//          self.onUpdates[petId] = true
            self.socket.emit("gpsPets", ["ids": [petId], "noLastPos": false])
        }
    }
    
    /// Stop pets GPS Updates
    ///
    /// - Parameter id: pet id
    func stopGPSUpdates(for id: Int) {
        
        if socket.status == .connected {
            self.onUpdates[id] = false
            
            Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "Stop Updates for pet: ", id)
            socket.emit(channel.startGPSUpdates.name, Int(id))
        }
    }
    

    private func handleGPSUpdates(_ data: [Any]) {
        if let json = data.first as? [String:Any] {
            if let id = json.tryCastInteger(for: "petId") {
                Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "GPS Updates \(id)")
                if let data = getGPSData(for: id) {
                    data.update(json)
                }else{
                    PetsGPSData.setObject(GPSData(json), forKey: NSNumber(integerLiteral: Int(id)))
                }
                NotificationManager.instance.postPetGPSUpdates(with: id)
            } else {
                Reporter.debugPrint(file: "\(#file)", function: "\(#function)", json)
            }
            
        } else{
            Reporter.debugPrint(file: "\(#file)", function: "\(#function)", data)
        }
    }
    
    //Events
    
    private func handleEventUpdated(_ data:[Any]){
        if let dict = data.first as? [String:Any] {
            
            let json = JSON(dict)
            let error = json["errors"].intValue
            
            if error != 0 {
                Reporter.send(file: "\(#file)", function: "\(#function)", NSError(domain: "Socket IO Handle Events", code: error, userInfo: dict))
            }else {
                NotificationManager.instance.post(Event(json))
            }
        } else{
            Reporter.send(file: "\(#file)", function: "\(#function)", NSError(domain: "Socket IO Handle Events", code: -1, userInfo: ["data":data]))
        }
    }
    
    // helpers
    
    private func getStatus(_ data: [Any]) -> SocketIOStatus {
        if let json = data.first as? [String:Any] {
            if let code = json["errors"] as? Int {
                return SocketIOStatus(rawValue: code) ?? SocketIOStatus.unknown
            }
            if let code = json["status"] as? Int {
                return SocketIOStatus(rawValue: code) ?? SocketIOStatus.unknown
            }
        }
        if let element = ((data as NSArray)[0] as? NSArray)?[0] as? String {
            return element == "unauthorized" ? SocketIOStatus.unauthorized : SocketIOStatus.unknown
        }
        Reporter.debugPrint(file: "\(#file)", function: "\(#function)", data, data.first as? [String:Any] ?? "", data as? [String] ?? "")
        return SocketIOStatus.unknown
    }
}

fileprivate enum channel {
    
    case connect, diconnect, auth, stopGPSUpdates, getPets, trips, pets, startGPSUpdates
    
    var name: String {
        switch self {
        case .connect: return "connect"
        case .diconnect: return "diconnect"
        case .trips: return "trips"
        case .auth: return "authCheck"
        case .pets: return "pets"
        //case .events: return "events"
        case .startGPSUpdates: return "room"
        case .stopGPSUpdates: return "roomleave"
        case .getPets: return "room"
        }
    }
    
    static func gpsUpdatesName(for petId: Int) -> String {
        return "gpsUpdates"
    }
    
    // to return pets.
    static func joinRoom(for petIds: [Int]) -> String {
        return "pets"
    }
}

fileprivate extension SocketIOClient {
    var isConnected: Bool {
        return self.status == SocketIOClientStatus.connected
    }
}
