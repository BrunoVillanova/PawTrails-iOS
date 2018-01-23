//
//  NotificationManager.swift
//  PawTrails
//
//  Created by Marc Perello on 08/06/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

enum listenerType: String {

    case gpsUpdates = "gpsUpdates"
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


/// Handles all notifications between classes in the app
class NotificationManager {
    
    var observers = [String:NSObjectProtocol]()
    
    static let instance = NotificationManager()
    
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
    
    //MARK:- GPSUpdates ALL
    
    /// Post Pet GPS Updates
    /// It sends updates for the collective notification channel of all the pets and the single one for the specific pet.
    /// - Parameter id: pet id
    func postPetGPSUpdates(with id: Int){
        self.post(Listener(.gpsUpdates), userInfo: ["id":id])
        self.post(Listener(.gpsUpdates, id), userInfo: ["id":id])
    }
    
    /// Get All Pets GPS Updates
    ///
    /// - Parameter callback: returns pet id and the GPS updates.
    func getPetGPSUpdates(_ callback: @escaping ((_ id: Int, _ data: GPSData)->())){
        self.addObserver(Listener(.gpsUpdates)) { (notification) in
            self.handlePetGPSUpdates(notification, callback)
        }
    }
    
    private func handlePetGPSUpdates(_ notification: Notification, _ callback: @escaping ((_ id: Int, _ data: GPSData)->())){
        if let petId = notification.userInfo?["id"] as? Int {
            if let updates = SocketIOManager.instance.getGPSData(for: petId) {
                if updates.locationAndTime == "" && !updates.point.coordinates.isDefaultZero {  GeocoderManager.Intance.reverse(type: .pet, with: updates.point, for: petId) }
                DispatchQueue.main.async {
                    callback(petId, updates)
                }
            }
        }

    }
    
    /// Removes All Pets GPS updates observer
    func removePetGPSUpdates() {
        self.removeObserver(Listener(.gpsUpdates))
    }
    
    //MARK:- GPSUpdates ONE
    
    /// Get Single Pet GPS Updates
    ///
    /// - Parameters:
    ///   - id: pet id
    ///   - callback: returns pet id and the GPS updates.
    func getPetGPSUpdates(for id: Int, _ callback: @escaping ((_ id: Int, _ data: GPSData)->())){
        
        self.addObserver(Listener(.gpsUpdates, id)) { (notification) in
            self.handlePetGPSUpdates(notification, callback)
        }
    }

    /// Removes Sinle Pet GPS updates observer
    func removePetGPSUpdates(of id: Int) {
        self.removeObserver(Listener(.gpsUpdates, id))
    }
    
    //MARK:- PetList
    
    /// Post Pet List Updates
    ///
    /// - Parameter pets: pets to send
    func postPetListUpdates(with pets: [Pet]){
        self.post(Listener(.petList), userInfo: ["gpsUpdates": pets])
    }
    
    /// Get PetList Updates
    ///
    /// - Parameter callback: retunrns list of pets
    func getPetListUpdates(_ callback: @escaping ((_ pets: [Pet])->())){
        
        self.addObserver(Listener(.petList)) { (notification) in
            if let pets = notification.userInfo?["pets"] as? [Pet] {
                DispatchQueue.main.async {
                    callback(pets)
                }
            }else{
                Reporter.send(file: "\(#file)", function: "\(#function)", NSError(domain: "Notification Manager", code: 0, userInfo: ["reason": "couldn't cast pets", "data": notification.userInfo ?? "no data"]))
            }
        }
    }
    
    /// Removes PetList updates observer
    func removePetListUpdates() {
        self.removeObserver(Listener(.petList))
    }
    
    //MARK:- PetGeoCodeUpdates
    
    /// Post Geocode Updates
    ///
    /// - Parameter code: code to send
    func postPetGeoCodeUpdates(with code: Geocode){
        self.post(Listener(.geoCode), userInfo: ["code": code])
    }
    
    /// Get Geocode Updates
    ///
    /// - Parameter callback: return geocode
    func getPetGeoCodeUpdates(_ callback: @escaping ((_ code: Geocode)->())){
        
        self.addObserver(Listener(.geoCode)) { (notification) in
            if let geocode = notification.userInfo?["code"] as? Geocode {
            DispatchQueue.main.async {
                callback(geocode)
            }
            }else{
                Reporter.send(file: "\(#file)", function: "\(#function)", NSError(domain: "Notification Manager", code: 1, userInfo: ["reason": "couldn't cast geocode", "data": notification.userInfo ?? "no data"]))
            }
        }
    }
    
    /// Removes geocode updates observer
    func removePetGeoCodeUpdates() {
        self.removeObserver(Listener(.geoCode))
    }
    
    //MARK:- Event
    
    /// Post Event Updates
    ///
    /// - Parameter event: event to send
    func post(_ event: Event){
        self.post(Listener(.events), userInfo: ["event": event])
    }
    
    /// Get Event Updates
    ///
    /// - Parameter callback: return event
    func getEventsUpdates(_ callback: @escaping ((_ event: Event)->())){
        
        self.addObserver(Listener(.events)) { (notification) in
            if let event = notification.userInfo?["event"] as? Event {
            DispatchQueue.main.async {
                callback(event)
            }
            }else{
                Reporter.send(file: "\(#file)", function: "\(#function)", NSError(domain: "Notification Manager", code: 1, userInfo: ["reason": "couldn't cast event", "data": notification.userInfo ?? "no data"]))
            }
        }
    }
    
    /// Removes event updates observer
    func removeEventsUpdates() {
        self.removeObserver(Listener(.events))
    }
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}