//
//  SafeZoneManager.swift
//  PawTrails
//
//  Created by Marc Perello on 17/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

typealias safezonesCallback = ((_ error:DataManagerError?, _ safezones:[SafeZone]?) -> Void)
typealias safezoneCallback = (_ error:DataManagerError?, _ safezone:SafeZone?) -> Void

class SafeZoneManager {
    
    
    static func upsert(_ data: [String:Any]) -> SafeZone? {
        
        if let id = data.tryCastInteger(for: "id") {
            
            do {
                if let safezone = try CoreDataManager.Instance.upsert("SafeZone", with: ["id":id]) as? SafeZone {
                    
                    safezone.name = data["name"] as? String
                    safezone.active = data["active"] as? Bool ?? false
                    if let shapeCode = data.tryCastInteger(for: "shape") {
                        if let shape = Shape(rawValue: Int16(shapeCode)) {
                            safezone.shape = shape.rawValue
                        }
                    }
                    
                    let p1 = safezone.point1
                    let p2 = safezone.point2
                    
                    if let point1Data = data["point1"] as? [String:Any] {
                        safezone.point1 = Point(point1Data)
                    }
                    
                    if let point2Data = data["point2"] as? [String:Any] {
                        safezone.point2 = Point(point2Data)
                    }
                    debugPrint(p1?.toDict ?? "")
                    debugPrint(safezone.point1?.toDict ?? "")
                    debugPrint(p1?.toDict ?? "")
                    debugPrint(safezone.point2?.toDict ?? "")
                    if p1 == nil || p2 == nil || (p1 != nil && p2 != nil && (p1 != safezone.point1 || p2 != safezone.point2)) {
                        safezone.preview = nil
                        safezone.address = nil
                        debugPrint("update safezone screen")
                    }
                    
                    
                    try CoreDataManager.Instance.save()
                    return safezone
                }
            } catch {
                debugPrint(error)
            }
        }
        return nil
    }
    
    static func upsertList(_ data: [String:Any], into petId: Int16) {
        
        if let safezonesData = data["safezones"] as? [[String:Any]] {
            
            PetManager.get(petId) { (error, pet) in
                if error == nil, let pet = pet {
                    
                    do {
                        
                        let safezones = pet.mutableSetValue(forKeyPath: "safezones")
                        safezones.removeAllObjects()
                        
                        for safezoneData in safezonesData {
                            if let safezone = upsert(safezoneData) {
                                safezones.add(safezone)
                            }
                        }
                        
                        pet.setValue(safezones, forKey: "safezones")
                        try CoreDataManager.Instance.save()
                    }catch{
                        debugPrint(error)
                    }
                }
            }
        }
    }
    
    static func set(safezone: SafeZone, imageData: Data){
        DispatchQueue.main.async {
            do {
                safezone.preview = imageData
                try CoreDataManager.Instance.save()
            }catch{
                debugPrint(error)
            }
        }
    }
    
    static func set(safezone: SafeZone, address: String){
        DispatchQueue.main.async {
            do {
                safezone.address = address
                try CoreDataManager.Instance.save()
            }catch{
                debugPrint(error)
            }
        }
    }
    
    
}
