//
//  SocketIOManagement.swift
//  PawTrails
//
//  Created by Marc Perello on 03/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import UIKit

class SocketIOManager: NSObject, URLSessionDelegate {
    
    static let Instance = SocketIOManager(SSLEnabled: true)
    
    private let urlString = "http://eu.pawtrails.pet:2003"
    private let urlStringSSL = "https://eu.pawtrails.pet:2004"
    private var socket: SocketIOClient!
    
    private var onUpdates = [Int16:Bool]()
    private var PetsGPSData = NSCache<NSNumber,GPSData>()
    //    private var queue = DispatchQueue(label: "SOCKET.IO", qos: .background)
    
    init(SSLEnabled: Bool = true) {
        super.init()
        
        //        queue.async {
        let urlString = SSLEnabled ? self.urlStringSSL : self.urlString
        
        if let url = URL(string: urlString) {
            self.socket = SocketIOClient(socketURL: url, config: [.log(false), .selfSigned(SSLEnabled), .secure(SSLEnabled), .sessionDelegate(self), .forceNew(true)])
        }
        
        for key in self.onUpdates.keys {  self.onUpdates[key] = false }
        //        }
    }
    
    
    func establishConnection(_ callback: (()->())? = nil) {
        //        queue.async {
        self.socket.on("authCheck") { (data, ack) in
            if self.isSuccessfullyConected(data), let callback = callback {
                debugPrint("Connected")
                callback()
            }else{
                debugPrint("Failed \(data)")
            }
        }
        self.socket.on("connect") { (data, ack) in
            if let token = SharedPreferences.get(.token) {
                debugPrint("Connecting")
                self.socket.emit("authCheck", with: [token])
            }
            
        }
        self.socket.on("events", callback: { (data, ack) in
            debugPrint("Event RS", data)
            self.handleEventUpdated(data)
        })
        self.socket.connect()
        //        }
    }
    
    
    func closeConnection() {
        //        queue.async {
        self.socket.disconnect()
        //        }
    }
    
    func isConnected() -> Bool {
        return socket.status == SocketIOClientStatus.connected
    }
    
    func connectionStatus() -> String {
        switch socket.status {
        case .notConnected: return "not connected"
        case .disconnected: return "disconnected"
        case .connecting: return "connecting"
        case .connected: return "connected"
        }
    }
    
    //Pet
    
    typealias socketIOCallback = (SocketIOError?,GPSData?) -> Void
    
    func getPetGPSData(id: Int16) -> GPSData? {
        return PetsGPSData.object(forKey: NSNumber(integerLiteral: Int(id)))
    }
    
    func setPetGPSlocationName(id: Int16, _ locationName: String){
        if let data = getPetGPSData(id:id) {
            data.locationAndTime = "\(locationName) - \(data.distanceTime)"
        }
    }
    
    func startGPSUpdates(for ids: [Int16]){
        
        if self.isConnected() {
            for id in ids {
                self.startPetGPSUpdates(for: id)
            }
        }else{
            self.establishConnection({
                self.startGPSUpdates(for: ids)
            })
        }
    }
    
    func startPetGPSUpdates(for id: Int16){
        //        queue.sync {
        if onUpdates[id] == nil || (onUpdates[id] != nil && onUpdates[id] == false) {
            //                queue.async {
            self.socket.on("gpsUpdate\(id)", callback: { (data, ack) in
//                debugPrint("gpsData Update response", data)
                self.handleGPSUpdates(data)
            })
            if self.isConnected() {
                self.startPetUpdates(for: id)
            }else{
                self.establishConnection({
                    self.startPetUpdates(for: id)
                })
            }
            //                }
        }
        //        }
    }
    
    private func startPetUpdates(for id: Int16) {
        
        if socket.status == .connected {
            //            queue.async {
            self.onUpdates[id] = true
            //            }
            debugPrint("Start Updates for pet: ", id)
            socket.emit("roomjoin", "\(Int(id))")
        }
    }
    
    private func stopPetUpdates(for id: Int16) {
        
        if socket.status == .connected {
            //            queue.async {
            self.onUpdates[id] = false
            //            }
            debugPrint("Stop Updates for pet: ", id)
            socket.emit("roomleave", "\(Int(id))")
        }
    }
    
    private func handleGPSUpdates(_ data: [Any]) {
        
        if let json = data.first as? [String:Any] {
            
            if let error = json["errors"] as? Int, error != 0 {
                //                debugPrint("Error :", error)
            }else if let id = json.tryCastInteger(for: "petId")?.toInt16 {
                debugPrint("GPS Updates \(id)")
                if let data = getPetGPSData(id: id) {
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
    
    private func isSuccessfullyConected(_ data: [Any]) -> Bool {
        if let json = data.first as? [String:Any] {
            return (json["errors"] as? Int) == 0
        }
        return false
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
