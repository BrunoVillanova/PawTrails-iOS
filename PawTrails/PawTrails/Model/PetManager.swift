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
typealias petUsersCallback = (_ error:PetError?, _ users:[PetUser]?) -> Void
typealias petTrackingCallback = (_ location:(Double, Double)) -> Void

import Foundation

class PetManager {
    
    
    static func upsertPet(_ data: [String:Any]) {
        
        do {
            if let pet = try CoreDataManager.Instance.upsert("Pet", with: data.filtered(by: ["type", "gender"])) as? Pet {
                
                pet.birthday = (data["date_of_birth"] as? String)?.toDate
                
                // Weight
                if let weightAmount = data["weight"] as? Double {
                    
//                    if pet.weight != nil {
//                        pet.weight?.amount = weightAmount
//                    }else{
                        pet.weight = Weight(weightAmount, unit: .kg)
//                    }
                }else{
                    pet.weight = nil
                }
                
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
                    if let breedId = data["breed"] as? Int {
                        pet.firstBreed = BreedManager.retrieve(for: type, breedId: "\(breedId)")
                    }else{
                        pet.setValue(nil, forKey: "firstBreed")
                    }
                    
                    // Second Breed
                    if let breedId = data["breed1"] as? Int {
                        pet.secondBreed = BreedManager.retrieve(for: type, breedId: "\(breedId)")
                    }else{
                        pet.setValue(nil, forKey: "secondBreed")
                    }
                }
                
                // Other Breed
                pet.breedDescription = data["breed_descr"] as? String
                
                try CoreDataManager.Instance.save()
            }
        } catch {
            debugPrint(error)
        }
    }
    
    static func upsertPets(_ data: [String:Any], _ callback:petsCallback){
        
        if let petsData = data["pets"] as? [[String:Any]] {
            for petData in petsData {
                upsertPet(petData)
            }
            getPets(callback)
        }else{
            callback(PetError.PetsNotFoundInResponse, nil)
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
    
    static func getFriends(callback: petUsersCallback){
        
        getPets { (error, pets) in
            
            if error == nil, let pets = pets {
                
                var friends = [PetUser]()
                //option 1
                for pet in pets {
                    if var users = pet.guests?.allObjects as? [PetUser] {
                        if let owner = pet.owner { users.append(owner) }
                        for user in users {
                            if !friends.contains(user) { friends.append(user) }
                        }
                    }
                }
                
                //                //option 2
                //                for pet in pets {
                //                    if let users = pet.guests?.allObjects as? [PetUser] { friends.append(contentsOf: users) }
                //                    if let owner = pet.owner { friends.append(owner) }
                //                }
                //                friends = Array(Set(friends))
                
                callback(nil, friends)
            }else{
                callback(error, nil)
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

