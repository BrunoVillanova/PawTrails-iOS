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


enum TripAction: Int {
    case initial = 0 // INITIAL VALUES
    case started = 2 // "action": 2 => Trip started (notify only to the trip owner) START
    case removed = 3 // "action": 3 => Trip removed (deleted) (notify only to the trip owner)
    case updated = 4 // "action": 4 => Trip updated (notify only to the trip owner) PAUSE / RESUME / STOP
    
    var name: String {
        switch self {
        case .initial: return "initial"
        case .started: return "started"
        case .removed: return "removed"
        case .updated: return "updated"
        }
    }
}

fileprivate enum channel {
    
    case connect, diconnect, auth, trips, pets, gpsUpdates
    
    var name: String {
        switch self {
        case .connect: return "connect"
        case .diconnect: return "diconnect"
        case .trips: return "trips"
        case .auth: return "authCheck"
        case .pets: return "pets"
        case .gpsUpdates: return "gpsUpdates"
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
    private var isAuthenticated = false
//    var petGpsUpdates: [PetDeviceData]?
    var petGpsUpdates: Variable<[PetDeviceData]> = Variable([PetDeviceData]())
    var petTrips: Variable<[Trip]> = Variable([Trip]())
    var isReadyForCommunication: Variable<Bool> = Variable(false)
    fileprivate var openChannels: Set<channel> = Set<channel>()
    
//    var petGpsUpdates: Observable<[PetDeviceData]?> = Observable.from(optional: [PetDeviceData]())
    
    init(SSLEnabled: Bool = true) {
        super.init()
        
        let urlString = SSLEnabled ? self.urlStringSSL : self.urlString
        
        if let url = URL(string: urlString) {
            self.socket = SocketIOClient(socketURL: url, config: [.log(false), .secure(true)])
        }
        
        // Init SocketIO
        socketReactive = Reactive<SocketIOClient>(socket)
        
        // Define SocketIO event handlers
        socketReactive?.on(channel.connect.name).subscribe(onNext: { (data) in
            print("SocketIO -> Connect \(data)")
            self.isConnected = true
            self.isConnecting = false
            self.socketAuth()
        }){}.disposed(by: disposeBag)
        
        
        socketReactive?.on(channel.auth.name).subscribe(onNext: { (data) in
            
            self.isAuthenticating = false
            let status = self.getStatus(data)
            print("SocketIO -> AuthCheck -> \(status) -> \(data)")
            if (status == .connected) {
                self.isAuthenticated = true
                print("SocketIO -> AuthCheck -> Authenticated and Ready for Communitcation")
                self.isReadyForCommunication.value = true
            } else if (status == .unauthorized || status == .unauthorized2) {
                //TODO: force user to login again
                self.userNotSigned()
               
            } else if (status != .waiting) {
                self.socketAuth()
            }
        }).addDisposableTo(self.disposeBag)
        
        
        socketReactive?.on(channel.diconnect.name).subscribe(onNext: { (data) in
            print("SocketIO -> Disconnect")
            self.isConnected = false
            self.isReadyForCommunication.value = false
        }){}.disposed(by: disposeBag)
        
        
        socketReactive?.on(channel.gpsUpdates.name).subscribe(onNext: { (data) in
            print("SocketIO -> GPS Updates")
            self.openChannels.insert(channel.gpsUpdates)
            self.petGpsUpdates.value = PetDeviceData.fromJson(data.first)!
        }).addDisposableTo(disposeBag)
        
        
        socketReactive?.on(channel.trips.name).subscribe(onNext: { (data) in
            print("SocketIO -> Trips")
            if let json = data.first as? [String:Any] {
                
                if let tripActionValue = json["action"] as? Int, let tripAction = TripAction(rawValue: tripActionValue) {
    
                    print("SocketIO -> Trips -> Action: \(tripAction.name)")
                    
                    if let tripsData = json["trips"] as? [[String:Any]] {
                        
                        var tripList = [Trip]()
                        
                        for tripJson in tripsData {
                            tripList.append(Trip(tripJson))
                            print("SocketIO -> Trips -> Trip: \(Trip(tripJson))")
                        }
                        
                        self.petTrips.value = tripList
                    }
                }
            }
        }).addDisposableTo(disposeBag)
        
        self.connect()
    }
    
    func userNotSigned() {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController, let storyboard = rootViewController.storyboard {
            if let vc = storyboard.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController {
                rootViewController.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func gpsUpdates(_ petIDs: [Int]) -> Observable<[PetDeviceData]> {
        return isReady().filter({ (isReady) -> Bool in
            return isReady
        }).flatMap({ (isReady) -> Observable<[PetDeviceData]> in
            self.socket.emit("gpsPets", ["ids": petIDs, "noLastPos": false])
            return self.petGpsUpdates.asObservable()
        })
    }
    
    func trips() -> Observable<[Trip]> {
        return isReady().filter({ (value) -> Bool in
            return value == true
        }).flatMap({ (isReady) -> Observable<[Trip]> in
            self.socket.emit(channel.trips.name)
            return self.petTrips.asObservable()
        })
    }
    
    func isReady() -> Observable<Bool> {
        return isReadyForCommunication.asObservable()
    }
    
    func socketAuth() {
        guard !isAuthenticating && isConnected else {
            return
        }
        
        let token = SharedPreferences.get(.token)
        if token != "" {
            Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "Connecting")
            isAuthenticating = true
            socket.emit(channel.auth.name, token)
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
    }
    
    /// Disconnects from Socket I.O.
    func disconnect() {
        self.socket.disconnect()
        self.isConnected = false
    }
    
    
    // MARK: establish connection with PetsList channel.
    func connectToPetChannel() {
        self.socket.emit("getPetList", false)
        self.socket.on("pets", callback: { (data, ack) in
            print("SocketIO pets")
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
    func startGPSUpdates(for petIds: [Int]) -> Observable<[PetDeviceData]> {
        print("SocketIO GPS Pets Emited for petIDs \(petIds)")
        return self.gpsUpdates(petIds)
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



fileprivate extension SocketIOClient {
    var isConnected: Bool {
        return self.status == SocketIOClientStatus.connected
    }
}
