//
//  SafeZoneManager.swift
//  PawTrails
//
//  Created by Marc Perello on 17/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

typealias safezonesCallback = ((_ error:DataManagerError?, _ safezones:[SafeZone]?) -> Void)
typealias safezoneCallback = ((_ error:DataManagerError?, _ safezone:SafeZone?) -> Void)

class SafeZoneManager {
    
    
    static func upsert(_ data: [String:Any], callback: safezoneCallback) {
        
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
                    if p1 == nil || p2 == nil || (p1 != nil && p2 != nil && (!p1!.isEqual(safezone.point1) || !p2!.isEqual(safezone.point2))) {
                        safezone.preview = nil
                        safezone.address = nil
                        debugPrint("had to reload ", safezone.id)
                    }

                    try CoreDataManager.Instance.save()
                    callback(nil, safezone)
                }else{
                    callback(DataManagerError(DBError: DatabaseError.Unknown), nil)
                }
            } catch {
                debugPrint(error)
                callback(DataManagerError(error: error), nil)
            }
        }else{
            callback(DataManagerError(responseError: ResponseError.IdNotFound), nil)
        }
    }
    
    static func upsert(_ data: [String:Any], into petId: Int16, callback: safezonesCallback? = nil) {
        
        
        PetManager.get(petId) { (error, pet) in
            if error == nil, let pet = pet {
                
                upsert(data, callback: { (error, safezone) in
                    
                    if error == nil, let safezone = safezone {
                        do {
                            let safezonesMutable = pet.mutableSetValue(forKeyPath: "safezones")
                            
                            if (safezonesMutable.allObjects as? [SafeZone])?.first(where: { $0.id == safezone.id }) == nil {
                                safezonesMutable.add(safezone)
                            }
                            
                            pet.setValue(safezonesMutable, forKey: "safezones")
                            try CoreDataManager.Instance.save()
                            if let callback = callback {
                                callback(nil, safezonesMutable.allObjects as? [SafeZone])
                            }
                        }catch{
                            debugPrint(error)
                            if let callback = callback {
                                callback(DataManagerError.init(error: error), nil)
                            }
                        }
                    }else if let error = error, let callback = callback {
                        callback(error, nil)
                    }
                })
                
            }else if let error = error, let callback = callback {
                callback(error, nil)
            }else if let callback = callback {
                debugPrint(error ?? "nil error", pet ?? "nil pet")
                callback(nil, nil)
            }
        }
    }
    
    static func upsertList(_ data: [String:Any], into petId: Int16) {
        
        if let safezonesData = data["safezones"] as? [[String:Any]] {
            
            PetManager.get(petId) { (error, pet) in
                if error == nil, let pet = pet {
                    
                    do {
                        
                        let safezones = pet.mutableSetValue(forKeyPath: "safezones")
                        safezones.removeAllObjects()
                        
                        for safezoneData in safezonesData {
                            upsert(safezoneData, callback: { (error, safezone) in
                                if error == nil, let safezone = safezone {
                                    safezones.add(safezone)
                                }
                            })
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
    
    static func set(address: String, for id: Int16){
        DispatchQueue.main.async {
            
            self.get(id, { (error, safezone) in
                if error == nil, let safezone = safezone {
                    do {
                        safezone.address = address
                        try CoreDataManager.Instance.save()
                    }catch{
                        debugPrint(error)
                    }
                }else if let error = error {
                    debugPrint(error)
                }
            })
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
    
    static func get(_ id:Int16, _ callback:safezoneCallback) {
        
        if let results = CoreDataManager.Instance.retrieve("SafeZone", with: NSPredicate("id", .equal, id)) as? [SafeZone] {
            if results.count > 1 {
                callback(DataManagerError.init(DBError: DatabaseError.DuplicatedEntry), nil)
            }else{
                callback(nil, results.first!)
            }
        }else{
            callback(DataManagerError.init(DBError: DatabaseError.NotFound), nil)
        }
    }

    
    
}
