//
//  UserManager.swift
//  PawTrails
//
//  Created by Marc Perello on 21/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//


typealias petCheckDeviceCallback = (_ isIdle:Bool) -> Void
typealias petErrorCallback = (_ error:PetError?) -> Void
typealias petCallback = (_ error:PetError?, _ pet:Pet?) -> Void
typealias petsCallback = (_ error:PetError?, _ pets:[Pet]?) -> Void
typealias petsSplittedCallback = (_ error:PetError?, _ owned:[Pet]?, _ shared:[Pet]?) -> Void
typealias petTrackingCallback = (_ location:(Double, Double)) -> Void

import Foundation

class PetManager {
    
    //MARK:- Pet Profile
    
    static func upsertPet(_ data: [String:Any], callback: petCallback? = nil) {
        
        do {
            
            if let id = data.tryCastInteger(for: "id") {
                
                if let pet = try CoreDataManager.Instance.upsert("Pet", with: ["id":id]) as? Pet {
                    
                    pet.name = data["name"] as? String
                    pet.weight = data["weight"] as? Double ?? -1.0
                    pet.neutered = data["neutered"] as? Bool ?? false
                    pet.birthday = (data["date_of_birth"] as? String)?.toDate

                    if let isOwner = data["is_owner"] as? Bool {
                        pet.isOwner =  isOwner
                    }
                    
                    if let typeCode = data["type"] as? String {
                        pet.type = Type.build(code: typeCode)?.rawValue ?? -1
                    }
                    
                    if let genderCode = data["gender"] as? String {
                        pet.gender = Gender.build(code: genderCode)?.rawValue ?? -1
                    }
                    
                    // Breeds
                    if let type = Type(rawValue: pet.type) {
                        
                        // First Breed
                        if let firstBreedId = data["breed"] as? Int {
                            BreedManager.retrieve(for: type, breedId: firstBreedId, callback: { (error, breed) in
                                if error == nil { pet.firstBreed = breed }
                            })
                        }else{
                            pet.setValue(nil, forKey: "firstBreed")
                        }
                        
                        // Second Breed
                        if let secondBreedId = data["breed1"] as? Int {
                            BreedManager.retrieve(for: type, breedId: secondBreedId, callback: { (error, breed) in
                                if error == nil { pet.secondBreed = breed }
                            })
                        }else{
                            pet.setValue(nil, forKey: "secondBreed")
                        }
                    }
                    pet.type_descr = data["type_descr"] as? String
                    
                    
                    // Image
                    
                    if let imageURL = data["img_url"] as? String {
                        
                        if pet.imageURL == nil || (pet.imageURL != nil && pet.imageURL != imageURL) {
                            pet.imageURL = imageURL
                            pet.image = Data.build(with: imageURL)
                        }
                    }
                    
                    try CoreDataManager.Instance.save()
                    
                    if let callback = callback {
                        callback(nil, pet)
                    }
                }
            }
            
        } catch {
            debugPrint(error)
            if let callback = callback {
                callback(PetError.PetNotFoundInResponse, nil)
            }
        }
        
    }
    
    static func upsertPetList(_ data: [String:Any]) {
        
        guard let id = data.tryCastInteger(for: "id") else { return }
        
        getPet(Int16(id), { (error, pet) in
            
            if let pet = pet {
                do{
                    if let name = data["name"] as? String {
                        pet.name = name
                    }
                    if let imageURL = data["img_url"] as? String {
                        
                        if pet.imageURL == nil || (pet.imageURL != nil && pet.imageURL != imageURL) {
                            pet.imageURL = imageURL
                            pet.image = Data.build(with: imageURL)
                        }
                    }
                    if let isOwner = data["is_owner"] as? Bool {
                        pet.isOwner =  isOwner
                    }
                    try CoreDataManager.Instance.save()
                }catch{
                    
                }
            }else{
                upsertPet(data)
            }
        })
    }
    
    static func upsertPets(_ data: [String:Any], _ callback:petsCallback){
        
        if let petsData = data["pets"] as? [[String:Any]] {
            getPets({ (error, pets) in
                //Update
                if let pets = pets {
                    var ids = pets.map({ $0.id })
                    for petData in petsData {
                        if let index = ids.index(of: petData["id"] as! Int16) {
                            ids.remove(at: index)
                        }
                        upsertPetList(petData)
                    }
                    for id in ids {
                        _ = removePet(id: id)
                    }
                    //Insert
                }else{
                    for petData in petsData {
                        upsertPetList(petData)
                    }
                }
                getPets(callback)
            })
        }else{
            callback(PetError.PetsNotFoundInResponse, nil)
        }
    }
    
    static func set(_ deviceCode: String, _ id: Int16, _ callback:petErrorCallback){
        getPet(id) { (error, pet) in
            if error == nil, let pet = pet {
                do {
                    pet.deviceCode = deviceCode
                    try CoreDataManager.Instance.save()
                    callback(nil)
                }catch {
                    debugPrint(error)
                    callback(PetError.PetsNotFoundInResponse)
                }
            }else{
                callback(error)
            }
        }
    }
    
    static func getPet(_ id:Int16, _ callback:petCallback) {
        
        if let results = CoreDataManager.Instance.retrieve("Pet", with: NSPredicate("id", .equal, id)) as? [Pet] {
            if results.count > 1 {
                callback(PetError.MoreThenOnePet, nil)
            }else{
                callback(nil, results.first!)
            }
        }else{
            callback(PetError.PetNotFoundInDataBase, nil)
        }
    }
    
    static func getPets(_ callback:petsCallback) {

        if let results = CoreDataManager.Instance.retrieve("Pet", sortedBy: [NSSortDescriptor(key: "name", ascending: true)]) as? [Pet] {
            if results.count > 0 {
                callback(nil, results)
            }else{
                callback(PetError.PetNotFoundInDataBase, nil)
            }
        }else{
            callback(PetError.PetNotFoundInDataBase, nil)
        }
    }
    
    static func removePet(id: Int16) -> Bool {
        do {
            try CoreDataManager.Instance.delete(entity: "Pet", withPredicate: NSPredicate("id", .equal, id))
            return true
        } catch {
            print(error)
        }
        return false
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

