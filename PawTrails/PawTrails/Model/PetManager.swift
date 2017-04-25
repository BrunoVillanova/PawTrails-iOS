//
//  UserManager.swift
//  PawTrails
//
//  Created by Marc Perello on 21/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//


typealias petUpsertCallback = (_ error:PetError?) -> Void
typealias petCallback = (_ error:PetError?, _ pet:Pet?) -> Void
typealias petsCallback = (_ error:PetError?, _ pets:[Pet]?) -> Void
typealias petUsersCallback = (_ error:PetError?, _ users:[_petUser]?) -> Void
typealias petTrackingCallback = (_ location:(Double, Double)) -> Void

import Foundation

class PetManager {
    
    
    static func upsertPet(_ data: [String:Any]) {
        
        do {
            if let pet = try CoreDataManager.Instance.upsert("Pet", with: data.filtered(by:["last_location", "owner", "guests"])) as? Pet {
                
                if let ownerData = data["owner"] as? [String:Any] {
                    
                    if pet.owner == nil { // Create
                        pet.owner = try CoreDataManager.Instance.store("PetUser", with: ownerData) as? PetUser
                        
                    }else{ // Update
                        for key in pet.owner!.keys {
                            pet.owner!.setValue(ownerData[key], forKey: key)
                        }
                    }
//                }else{ //Remove
//                    pet.setValue(nil, forKey: "owner")
                }

                try CoreDataManager.Instance.save()
            }
        } catch {
            debugPrint(error)
        }
    }
    
    static func getPet(_ id:Int, _ callback:petCallback) {
        
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

