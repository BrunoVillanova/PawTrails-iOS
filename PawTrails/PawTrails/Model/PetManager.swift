////
////  UserManager.swift
////  PawTrails
////
////  Created by Marc Perello on 21/02/2017.
////  Copyright © 2017 AttitudeTech. All rights reserved.
////
//
//
//typealias petCheckDeviceCallback = (_ isIdle:Bool) -> Void
//typealias petCallback = (_ error:DataManagerError?, _ pet:Pet?) -> Void
//typealias petsCallback = (_ error:DataManagerError?, _ pets:[Pet]?) -> Void
//typealias petsSplittedCallback = (_ error:DataManagerError?, _ owned:[Pet]?, _ shared:[Pet]?) -> Void
//typealias petTrackingCallback = (_ location:(Double, Double)) -> Void
//
//import Foundation
//
//class PetManager {
//    
//    //MARK:- Pet Profile
//    
//    static func upsert(_ data: [String:Any], callback: petCallback? = nil) {
//        
//        do {
//            
//            if let id = data.tryCastInteger(for: "id") {
//                
//                if let pet = try CoreDataManager.Instance.upsert("Pet", with: ["id":id]) as? Pet {
//                    
//                    pet.name = data["name"] as? String
//                    pet.weight = data["weight"] as? Double ?? -1.0
//                    pet.neutered = data["neutered"] as? Bool ?? false
//                    pet.birthday = (data["date_of_birth"] as? String)?.toDate
//
//                    if let isOwner = data["is_owner"] as? Bool {
//                        pet.isOwner =  isOwner
//                    }
//                    
//                    if let typeCode = data["type"] as? String {
//                        pet.type = Type.build(code: typeCode)?.rawValue ?? -1
//                    }
//                    
//                    if let genderCode = data["gender"] as? String {
//                        pet.gender = Gender.build(code: genderCode)?.rawValue ?? -1
//                    }
//                    
//                    // Breeds
//                    if let type = Type(rawValue: pet.type) {
//                        
//                        // First Breed
//                        if let firstBreedId = data["breed"] as? Int {
//                            BreedManager.retrieve(for: type, breedId: firstBreedId, callback: { (error, breed) in
//                                if error == nil { pet.firstBreed = breed }
//                            })
//                        }else{
//                            pet.setValue(nil, forKey: "firstBreed")
//                        }
//                        
//                        // Second Breed
//                        if let secondBreedId = data["breed1"] as? Int {
//                            BreedManager.retrieve(for: type, breedId: secondBreedId, callback: { (error, breed) in
//                                if error == nil { pet.secondBreed = breed }
//                            })
//                        }else{
//                            pet.setValue(nil, forKey: "secondBreed")
//                        }
//                    }
//                    pet.type_descr = data["type_descr"] as? String
//                    pet.breed_descr = data["breed_descr"] as? String
//                    
//                    
//                    // Image
//                    
//                    if let imageURL = data["img_url"] as? String {
//                        
//                        if pet.imageURL == nil || (pet.imageURL != nil && pet.imageURL != imageURL) {
//                            pet.imageURL = imageURL
//                            pet.image = Data.build(with: imageURL)
//                        }
//                    }
//                    
//                    try CoreDataManager.Instance.save()
//                    
//                    if let callback = callback {
//                        callback(nil, pet)
//                    }
//                    return
//                }
//                
//            }else{
//                if let callback = callback { callback(DataManagerError(responseError: ResponseError.IdNotFound), nil)}
//                return
//            }
//            
//        } catch {
//            debugPrint(error)
//            if let callback = callback { callback(DataManagerError(error: error), nil)}
//            return
//        }
//        if let callback = callback { callback(nil, nil) }
//        fatalError("Missing Something")
//    }
//    
//    private static func _upsertList(_ data: [String:Any]) {
//        
//        guard let id = data.tryCastInteger(for: "id") else { return }
//        
//        get(Int16(id), { (error, pet) in
//            
//            if let pet = pet {
//                do{
//                    if let name = data["name"] as? String {
//                        pet.name = name
//                    }
//                    if let imageURL = data["img_url"] as? String {
//                        
//                        if pet.imageURL == nil || (pet.imageURL != nil && pet.imageURL != imageURL) {
//                            pet.imageURL = imageURL
//                            pet.image = Data.build(with: imageURL)
//                        }
//                    }
//                    if let isOwner = data["is_owner"] as? Bool {
//                        pet.isOwner =  isOwner
//                    }
//                    try CoreDataManager.Instance.save()
//                }catch{
//                    
//                }
//            }else{
//                upsert(data)
//            }
//        })
//    }
//    
//    static func upsertList(_ data: [String:Any], _ callback:petsCallback){
//        
//        if let petsData = data["pets"] as? [[String:Any]] {
//            get({ (error, pets) in
//                //Update
//                if let pets = pets {
//                    var ids = pets.map({ $0.id })
//                    for petData in petsData {
//                        if let index = ids.index(of: petData["id"] as! Int16) {
//                            ids.remove(at: index)
//                        }
//                        _upsertList(petData)
//                    }
//                    for id in ids {
//                        _ = remove(id: id)
//                    }
//                    //Insert
//                }else{
//                    for petData in petsData {
//                        _upsertList(petData)
//                    }
//                }
//                
//                if ( pets != nil && pets!.count > 0) || petsData.count > 0 {
//                    get(callback)
//                }else{
//                    callback(nil, nil)
//                }
//            })
//        }else{
//            callback(DataManagerError(responseError: ResponseError.NotFound), nil)
//        }
//    }
//    
//    static func set(_ deviceCode: String, _ id: Int16, _ callback:errorCallback){
//        get(id) { (error, pet) in
//            if error == nil, let pet = pet {
//                do {
//                    pet.deviceCode = deviceCode
//                    try CoreDataManager.Instance.save()
//                    callback(nil)
//                }catch {
//                    debugPrint(error)
//                    callback(DataManagerError(error: error))
//                }
//            }else{
//                callback(DataManagerError(error: error))
//            }
//        }
//    }
//    
//    static func get(_ id:Int16, _ callback:petCallback) {
//        
//        if let results = CoreDataManager.Instance.retrieve("Pet", with: NSPredicate("id", .equal, id)) as? [Pet] {
//            if results.count > 1 {
//                callback(DataManagerError.init(DBError: DatabaseError.DuplicatedEntry), nil)
//            }else{
//                callback(nil, results.first!)
//            }
//        }else{
//            callback(DataManagerError.init(DBError: DatabaseError.NotFound), nil)
//        }
//    }
//    
//    static func get(_ callback:petsCallback) {
//
//        if let results = CoreDataManager.Instance.retrieve("Pet", sortedBy: [NSSortDescriptor(key: "name", ascending: true)]) as? [Pet] {
//            callback(nil, results)
//        }else{
//            callback(DataManagerError.init(DBError: DatabaseError.NotFound), nil)
//        }
//    }
//    
//    static func remove(id: Int16) -> Bool {
//        do {
//            try CoreDataManager.Instance.delete(entity: "Pet", withPredicate: NSPredicate("id", .equal, id))
//            return true
//        } catch {
//            print(error)
//        }
//        return false
//    }
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//}
//
