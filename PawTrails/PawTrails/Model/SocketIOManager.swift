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

class SocketIOManager: NSObject, URLSessionDelegate {
    
    static let Instance = SocketIOManager(SSLEnabled: true)
    
    private let urlString = "http://eu.pawtrails.pet:2003"
    private let urlStringSSL = "https://eu.pawtrails.pet:2004"
    
    private var socket: SocketIOClient!
    
    private var onUpdates = [Int:Bool]()
    private var PetsGPSData = NSCache<NSNumber,GPSData>()
    
    init(SSLEnabled: Bool = true) {
        super.init()
        
        let urlString = SSLEnabled ? self.urlStringSSL : self.urlString
        
        if let url = URL(string: urlString) {
            self.socket = SocketIOClient(socketURL: url, config: [.log(false), .selfSigned(SSLEnabled), .secure(SSLEnabled), .sessionDelegate(self), .forceNew(true)])
        }
        
        for key in self.onUpdates.keys {  self.onUpdates[key] = false }
    }
    
    func connect(_ callback: ((SocketIOStatus)->())? = nil) {

        self.socket.on(channel.auth.name) { (data, ack) in
            let status = self.getStatus(data)
            debugPrint(status)
            if status != .waiting, let callback = callback {
                callback(status)
            }
        }
        self.socket.on(channel.connect.name) { (data, ack) in
            let token = SharedPreferences.get(.token)
            if token != "" {
                debugPrint("Connecting")
                self.socket.emit(channel.auth.name, with: [token])
            }
            
        }
        self.socket.on(channel.events.name, callback: { (data, ack) in
            debugPrint("Event RS", data)
            self.handleEventUpdated(data)
        })
        self.socket.connect()

    }
    
    func disconnect() {
        self.socket.disconnect()
    }
    
    func isConnected() -> Bool {
        return socket.status == SocketIOClientStatus.connected
    }

    
    //Pet
    
    func getGPSData(for id: Int) -> GPSData? {
        return PetsGPSData.object(forKey: NSNumber(integerLiteral: Int(id)))
    }
    
    func set(_ locationName: String, for petId: Int){
        if let data = getGPSData(for: petId) {
            data.locationAndTime = "\(locationName) - \(data.distanceTime)"
        }
    }
    
    func startGPSUpdates(for petIds: [Int]){
        
        if socket.isConnected {
            for petId in petIds {
                self.startGPSUpdatesEffective(for: petId)
            }
        }else{
            connect({ (error) in
                if error == .connected {
                    self.startGPSUpdates(for: petIds)
                }
            })
        }
    }
    
    private func startGPSUpdatesEffective(for petId: Int) {
        
        if onUpdates[petId] == nil || (onUpdates[petId] != nil && onUpdates[petId] == false) {
            debugPrint("Start Updates for pet: ", petId)
            
            self.socket.on(channel.gpsUpdatesName(for: petId), callback: { (data, ack) in
                debugPrint("gpsData Update response", data)
                self.handleGPSUpdates(data)
            })
            self.onUpdates[petId] = true
            socket.emit(channel.startGPSUpdates.name, Int(petId))
        }
    }

    
    func stopGPSUpdates(for id: Int) {
        
        if socket.status == .connected {

            self.onUpdates[id] = false

            debugPrint("Stop Updates for pet: ", id)
            socket.emit(channel.startGPSUpdates.name, Int(id))
        }
    }
    
    private func handleGPSUpdates(_ data: [Any]) {
        
        if let json = data.first as? [String:Any] {
            
            if let error = json["error"] {
                debugPrint("SIO-Error :", error)
            }else if let id = json.tryCastInteger(for: "petId") {
                debugPrint("GPS Updates \(id)")
                if let data = getGPSData(for: id) {
                    data.update(json)
                }else{
                    PetsGPSData.setObject(GPSData(json), forKey: NSNumber(integerLiteral: Int(id)))
                }
                NotificationManager.Instance.postPetGPSUpdates(with: id)
            }else {
                debugPrint(json)
            }
        }else{
            debugPrint(data)
        }
    }
    
    //Events
    
    private func handleEventUpdated(_ data:[Any]){
        if let dict = data.first as? [String:Any] {
            
            let json = JSON(dict)
            let error = json["errors"].intValue
            
            if error != 0 {
                debugPrint("Error :", error)
            }else {
                NotificationManager.Instance.post(Event(json))
            }
        }else{
            debugPrint(data)
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
        debugPrint(data, data.first as? [String:Any] ?? "", data as? [String] ?? "")
        return SocketIOStatus.unknown
    }
    
    // URLSessionDelegate
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                var secresult = SecTrustResultType.invalid
                let status = SecTrustEvaluate(serverTrust, &secresult)
                
                if(errSecSuccess == status) {
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        let serverCertificateData = SecCertificateCopyData(serverCertificate)
                        let data = CFDataGetBytePtr(serverCertificateData)
                        let size = CFDataGetLength(serverCertificateData)
                        let cert1 = NSData(bytes: data, length: size)
                        let file_der = Bundle.main.path(forResource: "attitudetechie", ofType: "der")
                        
                        if let file = file_der {

                            if let cert2 = NSData(contentsOfFile: file) {
                                if cert1.isEqual(to: cert2 as Data) {
                                    completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

fileprivate enum channel {
    
    case connect, auth, events, startGPSUpdates, stopGPSUpdates
    
    var name: String {
        switch self {
        case .connect: return "connect"
        case .auth: return "authCheck"
        case .events: return "events"
        case .startGPSUpdates: return "roomjoin"
        case .stopGPSUpdates: return "roomleave"
        }
    }
    
    static func gpsUpdatesName(for petId: Int) -> String {
        return "gpsUpdate\(petId)"
    }
}

fileprivate extension SocketIOClient {
    
    var isConnected: Bool {
        return self.status == SocketIOClientStatus.connected
    }
}
































































