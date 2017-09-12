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

/// Performs communication with Socket IO Platform
class SocketIOManager: NSObject, URLSessionDelegate {
    
    /// Shared Instance
    static let instance = SocketIOManager(SSLEnabled: true)
    
    private let urlString = "http://eu.pawtrails.pet:2003"
    private let urlStringSSL = "https://eu.pawtrails.pet:4654"
    
    private var socket: SocketIOClient!
    
    private var onUpdates = [Int:Bool]()
    private var PetsGPSData = NSCache<NSNumber,GPSData>()
    
    public var isConnected = false
    
    init(SSLEnabled: Bool = true) {
        super.init()
        
        let urlString = SSLEnabled ? self.urlStringSSL : self.urlString
        
        if let url = URL(string: urlString) {
            self.socket = SocketIOClient(socketURL: url, config: [.log(false), .secure(true)])
        }
        
        for key in self.onUpdates.keys {  self.onUpdates[key] = false }
    }
    
    /// Establishes Connection with Socket IO, peforms login driven by token.
    ///
    /// - Parameter callback: returns socket IO connection status
    func connect(_ callback: ((SocketIOStatus)->())? = nil) {

        self.socket.on(channel.diconnect.name) { (_, _) in
            self.isConnected = false
        }
        
        self.socket.on(channel.auth.name) { (data, ack) in
            let status = self.getStatus(data)
            Reporter.debugPrint(file: "\(#file)", function: "\(#function)", status)
            if status != .waiting, let callback = callback {
                self.isConnected = true
                callback(status)
            }
        }
        self.socket.on(channel.connect.name) { (data, ack) in
            let token = SharedPreferences.get(.token)
            if token != "" {
                Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "Connecting")
                self.socket.emit(channel.auth.name, with: [token])
            }else{
                Reporter.send(file: "\(#file)", function: "\(#function)", NSError(domain: "Socket IO", code: -1, userInfo: ["reason": "missing token"]))
            }
            
        }
        self.socket.on(channel.events.name, callback: { (data, ack) in
            Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "Event RS", data)
            self.handleEventUpdated(data)
        })
        self.socket.connect()

    }
    
    /// Disconnects from Socket I.O.
    func disconnect() {
        self.isConnected = false
        self.socket.disconnect()
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
    /// - Parameter petIds: pet ids
    func startGPSUpdates(for petIds: [Int]){
        
        if isConnected {
            for petId in petIds {
                self.startGPSUpdatesEffective(for: petId)
            }
        }else{
            connect({ (status) in
                Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "connect answer: ", status)
                if status == .connected {
                    self.startGPSUpdates(for: petIds)
                }
            })
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
            
            self.socket.on(channel.gpsUpdatesName(for: petId), callback: { (data, ack) in
                Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "gpsData Update response", data)
                self.handleGPSUpdates(data)
            })
            self.onUpdates[petId] = true
            socket.emit(channel.startGPSUpdates.name, Int(petId))
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
            }else {
                Reporter.debugPrint(file: "\(#file)", function: "\(#function)", json)
            }

        }else{
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
        }else{
            Reporter.send(file: "\(#file)", function: "\(#function)", NSError(domain: "Socket IO Handle Events", code: -1, userInfo: ["data":data]))
        }
    }
    
    // helpers
    
    private func getStatus(_ data: [Any]) -> SocketIOStatus {
        if let json = data.first as? [String:Any] {
            if let code = json["error"] as? Int {
                return SocketIOStatus(rawValue: code) ?? SocketIOStatus.unknown
            }
            if let code = json["result"] as? Int {
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
    
    case connect, diconnect, auth, events, startGPSUpdates, stopGPSUpdates
    
    var name: String {
        switch self {
        case .connect: return "connect"
        case .diconnect: return "diconnect"
        case .auth: return "authCheck"
        case .events: return "events"
        case .startGPSUpdates: return "room"
        case .stopGPSUpdates: return "roomleave"
        }
    }
    
    static func gpsUpdatesName(for petId: Int) -> String {
        return "gpsUpdate"
    }
}

fileprivate extension SocketIOClient {
    
    var isConnected: Bool {
        return self.status == SocketIOClientStatus.connected
    }
}
