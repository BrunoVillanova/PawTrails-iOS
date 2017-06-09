//
//  NotificationManager.swift
//  PawTrails
//
//  Created by Marc Perello on 08/06/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

enum Listener: String {
    case gpsUpdates = "GPS"
    case petList = "PETLIST"
    case geoCode = "GEOCODE"
    case unknown = "-"
    
    var notificationName: NSNotification.Name {
        return Notification.Name(rawValue: self.rawValue)
    }
}

class NotificationManager {
    
    var observers = [String:NSObjectProtocol]()
    
    static let Instance = NotificationManager()
    
    private func post(_ listener: Listener, userInfo: [AnyHashable:Any]? = nil){
        NotificationCenter.default.post(Notification(name: listener.notificationName, object: nil, userInfo: userInfo))
    }
    
    private func addObserver(_ listener: Listener, callback: @escaping ((Notification)->Void)){
        observers[listener.rawValue] = NotificationCenter.default.addObserver(forName: listener.notificationName, object: nil, queue: nil, using: callback)
    }
    
    private func removeObserver(_ listener: Listener){
        if let observer = observers[listener.rawValue] {
            NotificationCenter.default.removeObserver(observer)
            observers.removeValue(forKey: listener.rawValue)
        }
    }
    
    
    //GPSUpdates
    
    func postPetGPSUpdates(with id: Int16){
        self.post(.gpsUpdates, userInfo: ["id":id])
    }
    
    func getPetGPSUpdates(_ callback: @escaping ((_ id: Int16, _ data: GPSData)->())){
        
        self.addObserver(.gpsUpdates) { (notification) in
            
            if let petID = notification.userInfo?["id"] as? Int16 {
                if let updates = SocketIOManager.Instance.getPetGPSData(id: petID) {
                    callback(petID, updates)
                }
            }
        }
    }
    
    func removePetGPSUpdates() {
        self.removeObserver(.gpsUpdates)
    }
    
    //PetList
    
    func postPetListUpdates(with pets: [Pet]){
        self.post(.petList, userInfo: ["pets": pets])
    }
    
    func getPetListUpdates(_ callback: @escaping ((_ pets: [Pet]?)->())){
        
        self.addObserver(.petList) { (notification) in
            callback(notification.userInfo?["pets"] as? [Pet])
        }
    }
    
    func removePetListUpdates() {
        self.removeObserver(.petList)
    }
    
    
    //PetGeoCodeUpdates
    
    func postPetGeoCodeUpdates(with code: Geocode){
        self.post(.geoCode, userInfo: ["code": code])
    }
    
    func getPetGeoCodeUpdates(_ callback: @escaping ((_ code: Geocode?)->())){
        
        self.addObserver(.geoCode) { (notification) in
            callback(notification.userInfo?["code"] as? Geocode)
        }
    }
    
    func removePetGeoCodeUpdates() {
        self.removeObserver(.geoCode)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
