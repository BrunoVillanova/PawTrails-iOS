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
typealias petTrackingCallback = (_ location:(Double, Double)) -> Void

import Foundation

class PetManager {
    
    //MARK:- Pet Profile
    
    static func upsertPet(_ data: [String:Any], callback: petCallback? = nil) {
        
        do {
            if let pet = try CoreDataManager.Instance.upsert("Pet", with: data.filtered(by: ["type", "gender"])) as? Pet {
                
                pet.birthday = (data["date_of_birth"] as? String)?.toDate
                
                // Weight
//                if let weightAmount = data["weight"] as? Double {
//                    
//                    //                    if pet.weight != nil {
//                    //                        pet.weight?.amount = weightAmount
//                    //                    }else{
//                    pet.weight = Weight(weightAmount, unit: .kg)
//                    //                    }
//                }else{
//                    pet.weight = nil
//                }
                
                //Details
                
                if let typeCode = data["type"] as? String {
                    if let type = Type.build(code: typeCode)?.rawValue {
                        pet.type = Int16(type)
                    }else{
                        pet.type = -1
                    }
                }
                
                if let genderCode = data["gender"] as? String {
                    if let gender = Gender.build(code: genderCode)?.rawValue {
                        pet.gender = Int16(gender)
                    }else{
                        pet.gender = -1
                    }
                }
                
                // Breeds
                if let type = Type(rawValue: Int(pet.type)) {
                    
                    // First Breed
                    if let firstBreedId = data["breed"] as? Int {
                        pet.firstBreed = BreedManager.retrieve(for: type, breedId: "\(firstBreedId)")
                    }else{
                        pet.setValue(nil, forKey: "firstBreed")
                    }
                    
                    // Second Breed
                    if let secondBreedId = data["breed1"] as? Int {
                        pet.secondBreed = BreedManager.retrieve(for: type, breedId: "\(secondBreedId)")
                    }else{
                        pet.setValue(nil, forKey: "secondBreed")
                    }
                }
                
                // Image
                
                if let imageURL = data["img_url"] as? String {
                    
                    if pet.imageURL == nil || (pet.imageURL != nil && pet.imageURL != imageURL) {
                        pet.imageURL = imageURL
                        if let url = URL(string: imageURL) {
                            try pet.image = Data(contentsOf: url) as NSData
                        }
                    }
                }
                
                try CoreDataManager.Instance.save()
                
                if let callback = callback {
                    callback(nil, pet)
                }
            }else if let callback = callback {
                callback(PetError.PetNotFoundInResponse, nil)
            }

        } catch {
            debugPrint(error)
            if let callback = callback {
                callback(PetError.PetNotFoundInResponse, nil)
            }
        }
        
    }
    
    static func upsertPetList(_ data: [String:Any]) {
        
        guard let id = data["id"] as? String else { return }
        
        getPet(id, { (error, pet) in
            
            if let pet = pet {
                if let name = data["name"] as? String {
                    pet.name = name
                }
                if let imageURL = data["img_url"] as? String {
                    
                    if pet.imageURL == nil || (pet.imageURL != nil && pet.imageURL != imageURL) {
                        pet.imageURL = imageURL
                        if let url = URL(string: imageURL) {
                            do {
                                try pet.image = Data(contentsOf: url) as NSData
                            } catch {
                                debugPrint(error)
                            }
                        }
                    }
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
                    var ids = pets.map({ $0.id! })
                    for petData in petsData {
                        if let index = ids.index(of: petData["id"] as! String) {
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
            })
            getPets(callback)
        }else{
            callback(PetError.PetsNotFoundInResponse, nil)
        }
    }
    
    static func set(_ deviceCode: String, _ id: String, _ callback:petErrorCallback){
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
    
    static func getPet(_ id:String, _ callback:petCallback) {
        
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
        
        if let results = CoreDataManager.Instance.retrieve("Pet") as? [Pet] {
            if results.count > 0 {
                callback(nil, results)
            }else{
                callback(PetError.PetNotFoundInDataBase, nil)
            }
        }else{
            callback(PetError.PetNotFoundInDataBase, nil)
        }
    }
    
    static func removePet(id: String) -> Bool {
        do {
            try CoreDataManager.Instance.delete(entity: "Pet", withPredicate: NSPredicate("id", .equal, id))
            return true
        } catch {
            print(error)
        }
        return false
    }
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

