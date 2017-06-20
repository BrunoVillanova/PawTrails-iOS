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
    
    static let Instance = SocketIOManager()
    
    private let urlString = "wss://eu.pawtrails.pet:2004"
    private var socket: SocketIOClient!
    
    private var onUpdates = [Int16:Bool]()
    private var PetsGPSData = NSCache<NSNumber,GPSData>()
    private var queue = DispatchQueue(label: "SOCKET.IO", qos: .background)
    
    override init() {
        super.init()
        //        socket = SocketIOClient(socketURL: URL(string: urlString)!, config: [.log(true)])
        socket = SocketIOClient(socketURL: URL(string: urlString)!, config: [.log(false), .selfSigned(true), .secure(true), .sessionDelegate(self)])
//        socket = SocketIOClient(socketURL: URL(string: urlString)!)
        for key in onUpdates.keys {
            onUpdates[key] = false
        }
    }
    
    
    func establishConnection(_ callback: (()->())? = nil) {
        socket.on("authCheck") { (data, ack) in
            if self.isSuccessfullyConected(data), let callback = callback {
                debugPrint("Connected")
                callback()
            }else{
                debugPrint("Failed \(data)")
            }
        }
        socket.on("connect") { (data, ack) in
            if let token = SharedPreferences.get(.token) {
                debugPrint("Connecting")
                self.socket.emit("authCheck", with: [token])
            }
            
        }
        socket.on("events", callback: { (data, ack) in
            debugPrint("Event RS", data)
            self.handleEventUpdated(data)
        })
        socket.connect()
    }
    
    
    func closeConnection() {
        socket.disconnect()
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
    
    func startPetGPSUpdates(for id: Int16){
        if onUpdates[id] != nil && onUpdates[id]! {
           debugPrint("Already receiving updates!")
        }else{
            socket.on("gpsData", callback: { (data, ack) in
//                debugPrint("gpsData Update response", data)
                self.handleGPSUpdates(data)
            })
            if isConnected() {
                self.startPetUpdates(for: id)
            }else{
                establishConnection({
                    self.startPetUpdates(for: id)
                })
            }
        }
    }
    
    private func startPetUpdates(for id: Int16) {
        
        if socket.status == .connected {
            onUpdates[id] = true
            socket.emit("room", "\(Int(id))")
        }
    }
    
    private func stopPetUpdates(for id: Int16) {
        
        if socket.status == .connected {
            onUpdates[id] = false
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
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let serverTrust = challenge.protectionSpace.serverTrust
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust!))
        }
    }
    
}

//class SocketIOManager: NSObject {
//    
//    static let Instance = SocketIOManager()
//    
//    
//    private var socket: SocketIOClient = SocketIOClient(socketURL: URL(string: "http://192.168.1.4:3000")!)
//    
//    override init() {
//        super.init()
//    }
//    
//    
//    func establishConnection() {
//        socket.connect()
//    }
//    
//    
//    func closeConnection() {
//        socket.disconnect()
//    }
//    
//    
//    func connectToServerWithNickname(_ nickname: String, completionHandler: @escaping (_ userList: [[String: AnyObject]]?) -> Void) {
//        socket.emit("connectUser", nickname)
//        
//        socket.on("userList") { ( dataArray, ack) -> Void in
//            completionHandler(dataArray[0] as? [[String: AnyObject]])
//        }
//        
//        listenForOtherMessages()
//    }
//    
//    
//    func exitChatWithNickname(_ nickname: String, completionHandler: () -> Void) {
//        socket.emit("exitUser", nickname)
//        completionHandler()
//    }
//    
//    
//    func sendMessage(_ message: String, withNickname nickname: String) {
//        
//        if socket.status == SocketIOClientStatus.connected {
//            socket.emit("chatMessage", nickname, message)
//        }else{
//            print(socket.status)
//        }
//    }
//    
//    
//    func getChatMessage(_ completionHandler: @escaping (_ messageInfo: [String: AnyObject]) -> Void) {
//        socket.on("newChatMessage") { (dataArray, socketAck) -> Void in
//            var messageDictionary = [String: Any]()
//            messageDictionary["nickname"] = dataArray[0] as! String
//            messageDictionary["message"] = dataArray[1] as! String
//            messageDictionary["date"] = dataArray[2] as! String
//            
//            completionHandler(messageDictionary as [String : AnyObject])
//        }
//    }
//    
//    
//    fileprivate func listenForOtherMessages() {
//        socket.on("userConnectUpdate") { (dataArray, socketAck) -> Void in
//            NotificationCenter.default.post(name: Notification.Name(rawValue: "userWasConnectedNotification"), object: dataArray[0] as! [String: AnyObject])
//        }
//        
//        socket.on("userExitUpdate") { (dataArray, socketAck) -> Void in
//            NotificationCenter.default.post(name: Notification.Name(rawValue: "userWasDisconnectedNotification"), object: dataArray[0] as! String)
//        }
//        
//        socket.on("userTypingUpdate") { (dataArray, socketAck) -> Void in
//            NotificationCenter.default.post(name: Notification.Name(rawValue: "userTypingNotification"), object: dataArray[0] as? [String: AnyObject])
//        }
//    }
//    
//    
//    func sendStartTypingMessage(_ nickname: String) {
//        socket.emit("startType", nickname)
//    }
//    
//    
//    func sendStopTypingMessage(_ nickname: String) {
//        socket.emit("stopType", nickname)
//    }
//}

