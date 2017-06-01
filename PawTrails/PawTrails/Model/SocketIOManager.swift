//
//  SocketIOManagement.swift
//  PawTrails
//
//  Created by Marc Perello on 03/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

//
//  SocketIOManager.swift
//  SocketChat
//
//  Created by Gabriel Theodoropoulos on 1/31/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

enum Listener: String {
    case gpsUpdates = "GPS"
    case unknown = "-"
    
    var notificationName: NSNotification.Name {
        return Notification.Name(rawValue: self.rawValue)
    }
}

class SocketIOManager: NSObject {
    
    static let Instance = SocketIOManager()
    
    private let urlString = "http://eu.pawtrails.pet:4654"
    private var socket: SocketIOClient!
    
    private var openGPSUpdates = [Int16:Bool]()
    
    override init() {
        if let token = SharedPreferences.get(.token) {
//            socket = SocketIOClient(socketURL: URL(string: urlString)!, config: [.connectParams(["token":token, "user":"94"]), .log(true)])
            socket = SocketIOClient(socketURL: URL(string: urlString)!, config: [.connectParams(["token":token, "user":"94"])])
        }else {
            socket = SocketIOClient(socketURL: URL(string: urlString)!)
        }
        super.init()
    }
    
    
    func establishConnection() {
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
    
    func getPetGPSData(id: Int16, withUpdates: Bool = false, callback: @escaping ((GPSData?)->())){
        
        if withUpdates {
            socket.on("gpsData", callback: { (data, ack) in
                debugPrint("gpsData Update response", data, ack)
                callback(self.handleGPSUpdates(data))
            })
        }else{
            socket.once("gpsData", callback: { (data, ack) in
                debugPrint("gpsData response", data, ack)
                callback(self.handleGPSUpdates(data))
            })
        }
        
        if isConnected() {
            self.startPetUpdates(for: 25)
        }else{
            socket.on("connect") { (data, ack) in
                self.startPetUpdates(for: 25)
            }
            socket.connect()
        }
    }
    
    
    func startPetUpdates(for id: Int16) {
        
        if socket.status == .connected {
            socket.emit("room", "\(Int(id))")
        }
    }
    
    private func handleGPSUpdates(_ data: [Any]) -> GPSData? {
        
        if let json = data.first as? [String:Any] {
            
            if let error = json["errors"] as? Int, error != 0 {
                debugPrint(error)
            }else if let infoGPS = json["terminalgps"] as? [String:Any] {
                return GPSData(infoGPS)
                //                NotificationCenter.default.post(Notification.init(name: Listeners.gpsUpdates.notificationName, object: info, userInfo: nil))
            }
        }
        return nil
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

