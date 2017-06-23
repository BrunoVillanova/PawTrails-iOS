//
//  NotificationManager.swift
//  PawTrails
//
//  Created by Marc Perello on 08/06/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

enum listenerType: String {

    case gpsUpdates = "GPS"
    case petList = "PETLIST"
    case geoCode = "GEOCODE"
    case events = "EVENTS"
    case unknown = "-"
}

struct Listener {
    
    var type: listenerType
    var key: Any?
    
    init(_ type: listenerType, _ key: Any? = nil) {
        self.type = type
        self.key = key
    }
    
    var name: String {
        return key != nil ? self.type.rawValue.appending("\(key!)") : self.type.rawValue
    }
    
    var notificationName: NSNotification.Name {
        return Notification.Name(rawValue: name)
    }
}


class NotificationManager {
    
    var observers = [String:NSObjectProtocol]()
    
    static let Instance = NotificationManager()
    
    private func post(_ listener: Listener, userInfo: [AnyHashable:Any]? = nil){
        NotificationCenter.default.post(Notification(name: listener.notificationName, object: nil, userInfo: userInfo))
    }
    
    private func addObserver(_ listener: Listener, callback: @escaping ((Notification)->Void)){
        observers[listener.name] = NotificationCenter.default.addObserver(forName: listener.notificationName, object: nil, queue: nil, using: callback)
    }
    
    private func removeObserver(_ listener: Listener){
        if let observer = observers[listener.name] {
            NotificationCenter.default.removeObserver(observer)
            observers.removeValue(forKey: listener.name)
        }
    }
    
    
    //GPSUpdates ALL
    
    func postPetGPSUpdates(with id: Int16){
        self.post(Listener(.gpsUpdates), userInfo: ["id":id])
        self.post(Listener(.gpsUpdates, id), userInfo: ["id":id])
    }
    
    func getPetGPSUpdates(_ callback: @escaping ((_ id: Int16, _ data: GPSData)->())){
        
        self.addObserver(Listener(.gpsUpdates)) { (notification) in
            if let petId = notification.userInfo?["id"] as? Int16 {
                if let updates = SocketIOManager.Instance.getGPSData(for: petId) {
                    if updates.locationAndTime == "" && !updates.point.coordinates.isDefaultZero {  GeocoderManager.Intance.reverse(type: .pet, with: updates.point, for: petId) }
                    callback(petId, updates)
                }
            }
        }
    }
    
    func removePetGPSUpdates() {
        self.removeObserver(Listener(.gpsUpdates))
    }
    
    //GPSUpdates ONE
    
    func getPetGPSUpdates(for id: Int16, _ callback: @escaping ((_ id: Int16, _ data: GPSData)->())){
        
        self.addObserver(Listener(.gpsUpdates, id)) { (notification) in
            if let petId = notification.userInfo?["id"] as? Int16 {
                if let updates = SocketIOManager.Instance.getGPSData(for: petId) {
                    if updates.locationAndTime == "" && !updates.point.coordinates.isDefaultZero {  GeocoderManager.Intance.reverse(type: .pet, with: updates.point, for: petId) }
                    callback(petId, updates)
                }
            }
        }
    }
    
    func removePetGPSUpdates(of id: Int16) {
        self.removeObserver(Listener(.gpsUpdates, id))
    }
    
    //PetList
    
    func postPetListUpdates(with pets: [Pet]){
        self.post(Listener(.petList), userInfo: ["pets": pets])
    }
    
    func getPetListUpdates(_ callback: @escaping ((_ pets: [Pet]?)->())){
        
        self.addObserver(Listener(.petList)) { (notification) in
            callback(notification.userInfo?["pets"] as? [Pet])
        }
    }
    
    func removePetListUpdates() {
        self.removeObserver(Listener(.petList))
    }
    
    //PetGeoCodeUpdates
    
    func postPetGeoCodeUpdates(with code: Geocode){
        self.post(Listener(.geoCode), userInfo: ["code": code])
    }
    
    func getPetGeoCodeUpdates(_ callback: @escaping ((_ code: Geocode?)->())){
        
        self.addObserver(Listener(.geoCode)) { (notification) in
            callback(notification.userInfo?["code"] as? Geocode)
        }
    }
    
    func removePetGeoCodeUpdates() {
        self.removeObserver(Listener(.geoCode))
    }
    
    //Event
    
    func post(_ event: Event){
        self.post(Listener(.events), userInfo: ["event": event])
    }
    
    func getEventsUpdates(_ callback: @escaping ((_ event: Event?)->())){
        
        self.addObserver(Listener(.events)) { (notification) in
            callback(notification.userInfo?["event"] as? Event)
        }
    }
    
    func removeEventsUpdates() {
        self.removeObserver(Listener(.events))
    }
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
