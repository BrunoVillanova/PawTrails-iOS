//
//  SocketIOManagement.swift
//  Snout
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

class SocketIOManager: NSObject {
    
    static let Instance = SocketIOManager()
    
//    enum Notifications: String {
//        case receivedPoint = "receivedPoint"
//    }
   
    private var socket: SocketIOClient = SocketIOClient(socketURL: URL(string: "http://192.168.1.10:3000")!)
//    private var socket: SocketIOClient = SocketIOClient(socketURL: URL(string: "http://localhost:3000")!)
    
//    private var socket: SocketIOClient {
//        if #available(iOS 10.0, *) {
//            return SocketIOClient(socketURL: URL(string: "http://192.168.1.7:3000")!)
//        } else {
//            return SocketIOClient(socketURL: URL(string: "http://localhost:3000")!)
//        }
//    }
    
    override init() {
        super.init()
    }
    
    
    func establishConnection() {
        socket.connect()
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func connectionStatus() -> String {
        switch socket.status {
        case .notConnected: return "not connected"
        case .disconnected: return "disconnected"
        case .connecting: return "connecting"
        case .connected: return "connected"
        }
    }
    
    func launch(name:String, frequency: Int = 1000) -> Bool {
        if socket.status == SocketIOClientStatus.connected {
            socket.emit("launch", self.masc(name), frequency)
        }else{
            print(connectionStatus())
        }
        return socket.status == SocketIOClientStatus.connected
    }
    
    func stop(name:String){
        if socket.status == SocketIOClientStatus.connected {
            
            socket.emit("stop", self.masc(name))
        }else{
            print(socket.status.rawValue)
        }
    }
    
    func listen(name:String, _ completionHandler: @escaping (_ latitude:Double, _ longitude:Double) -> Void) {
        socket.on(self.masc(name)) { (dataArray, socketAck) -> Void in
            guard let lat = dataArray[0] as? Double else {
                print(dataArray[0])
                completionHandler(0,0)
                return
            }
            guard let long = dataArray[1] as? Double else {
                print(dataArray[0])
                completionHandler(0,0)
                return
            }
            completionHandler(lat,long)
        }
    }
    
    private func masc(_ name:String) -> String {
        if let id = UIDevice.current.identifierForVendor?.description {
            return name + id
        }
        return name
    }
    
//    func startListeningUpdates() {
//        socket.on("points") { (dataArray, socketAck) -> Void in
//            print(dataArray)
//            NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.receivedPoint.rawValue), object: dataArray[0] as! [String: Any])
//        }
//    }

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

