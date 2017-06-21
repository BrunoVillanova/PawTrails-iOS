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

fileprivate enum channel {
    
    case connect, auth, events, gpsUpdates, startGPSUpdates, stopGPSUpdates
    
    func getName(with key: Any? = nil) -> String {
        let key = key != nil ? "\(key!)" : ""
        switch self {
        case .connect: return "connect"
        case .auth: return "authCheck"
        case .events: return "events"
        case .gpsUpdates: return "gpsUpdate\(key)"
        case .startGPSUpdates: return "roomjoin"
        case .stopGPSUpdates: return "roomleave"
        }
    }
}

fileprivate extension SocketIOClient {
    
    var isConnected: Bool {
        return self.status == SocketIOClientStatus.connected
    }
    
    func once(channel: channel, key: Any? = nil, callback: @escaping NormalCallback) {
        self.once(channel.getName(with: key), callback: callback)
    }
    
    func on(channel: channel, key: Any? = nil, callback: @escaping NormalCallback) {
        self.on(channel.getName(with: key), callback: callback)
    }
    
    func off(channel: channel, key: Any? = nil) {
        
        self.off(channel.getName(with: key))
    }
    
    func emit(channel: channel, key: Any? = nil, items: SocketData...){
        self.emit(channel.getName(with: key), items)
    }
}


class SocketIOManager: NSObject, URLSessionDelegate {
    
    static let Instance = SocketIOManager(SSLEnabled: false)
    
    private let urlString = "http://eu.pawtrails.pet:2003"
    private let urlStringSSL = "https://eu.pawtrails.pet:2004"
    
    private var socket: SocketIOClient!
    
    private var onUpdates = [Int16:Bool]()
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

        self.socket.on(channel: .auth) { (data, ack) in

            let status = self.getStatus(data)
            debugPrint(status)
            if status != .waiting {
                if let callback = callback { callback(status) }
                self.socket.off(channel: .auth)
            }
        }
        self.socket.once(channel: .connect) { (data, ack) in
            if let token = SharedPreferences.get(.token) {
                debugPrint("Connecting with token: ", token)
                self.socket.emit(channel: .auth, items: [token])
            }
            
        }
        self.socket.on(channel: .events, callback: { (data, ack) in
            debugPrint("Event RS", data)
            self.handleEventUpdated(data)
        })
        self.socket.connect()

    }
    
    func disconnect() {
        self.socket.disconnect()
    }
    
    //Pet
    
    func getGPSData(for id: Int16) -> GPSData? {
        return PetsGPSData.object(forKey: NSNumber(integerLiteral: Int(id)))
    }
    
    func set(_ locationName: String, for petId: Int16){
        if let data = getGPSData(for: petId) {
            data.locationAndTime = "\(locationName) - \(data.distanceTime)"
        }
    }
    
    func startGPSUpdates(for petIds: [Int16]){
        
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
    
    private func startGPSUpdatesEffective(for petId: Int16) {
        
        if onUpdates[petId] == nil || (onUpdates[petId] != nil && onUpdates[petId] == false) {
            debugPrint("Start Updates for pet: ", petId)
            
            self.socket.on(channel: .gpsUpdates, key: petId, callback: { (data, ack) in
                self.handleGPSUpdates(data)
            })
            self.onUpdates[petId] = true
            self.socket.emit(channel: .startGPSUpdates, items: Int(petId))
        }
    }
    
    private func stopGPSUpdates(for petId: Int16) {
        
        if self.socket.status == .connected {
            debugPrint("Stop Updates for pet: ", petId)
            
            self.socket.off(channel: .gpsUpdates, key: petId)
            self.onUpdates[petId] = false
            self.socket.emit(channel: .stopGPSUpdates, items: Int(petId))
        }
    }
    
    private func handleGPSUpdates(_ data: [Any]) {
        
        if let json = data.first as? [String:Any] {
            
            if let error = json["errors"] as? Int, error != 0 {

            }else if let id = json.tryCastInteger(for: "petId")?.toInt16 {

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
        if let json = data.first as? [String:Any] {
            
            if let error = json["errors"] as? Int, error != 0 {
                debugPrint("Error :", error)
            }else {
                NotificationManager.Instance.post(Event(data: json))
            }
        }else{
            debugPrint(data)
        }
    }
    
    // helpers
    
    private func getStatus(_ data: [Any]) -> SocketIOStatus {
        debugPrint(data, data.first as? [String:Any] ?? "", data as? [String] ?? "")
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

































































