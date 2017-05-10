//
//  PetUserManager.swift
//  PawTrails
//
//  Created by Marc Perello on 09/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

typealias petUsersCallback = (_ error:PetError?, _ users:[PetUser]?) -> Void

class PetUserManager {
    

    static func upsert(_ data: [String:Any]) -> PetUser? {
        do {
            if let user = try CoreDataManager.Instance.upsert("PetUser", with: data) as? PetUser {
                
                // Image
                
                if let imageURL = data["img_url"] as? String {
                    
                    if user.imageURL == nil || (user.imageURL != nil && user.imageURL != imageURL) {
                        user.imageURL = imageURL
                        if let url = URL(string: imageURL) {
                            try user.image = Data(contentsOf: url) as NSData
                        }
                    }
                }
                
                user.isOwner = data["is_owner"] as? Bool ?? false
                
                return user
            }
        } catch {
            debugPrint(error)
        }
        return nil
    }
    
    static func upsert(_ data: [String:Any], into petId: String){
        
        if let petUsersData = data["users"] as? [[String:Any]] {
            PetManager.getPet(petId) { (error, pet) in
                if let pet = pet {
                    do {
                        let users = pet.mutableSetValue(forKey: "users")
                        users.removeAllObjects()
                        
                        for petUserData in petUsersData {
                            if let petUser = upsert(petUserData) {
                                users.add(petUser)
                            }
                        }
                        pet.setValue(users, forKey: "users")
                        try CoreDataManager.Instance.save()
                    }catch{
                        debugPrint(error)
                    }
                }
            }
        }
    }
    
    static func upsertFriends(_ data: [String:Any]){
        
        if let petUsersData = data["users"] as? [[String:Any]] {
            
            UserManager.get({ (error, user) in
                if let user = user {
                    do {
                        let friends = user.mutableSetValue(forKey: "friends")
                        friends.removeAllObjects()
                        
                        for petUserData in petUsersData {
                            if let petUser = upsert(petUserData) {
                                friends.add(petUser)
                            }
                        }
                        user.setValue(friends, forKey: "friends")
                        try CoreDataManager.Instance.save()
                    }catch{
                        debugPrint(error)
                    }
                }
            })
        }
    }
    
    static func get(for petId:String, callback: @escaping petUsersCallback){
        PetManager.getPet(petId) { (error, pet) in
            if let pet = pet, let users = pet.users?.allObjects as? [PetUser] {
                callback(nil, users)
            }else{
                callback(PetError.MoreThenOnePet, nil)
            }
        }
    }
    
    static func getFriends(callback: petUsersCallback){
        
        UserManager.get({ (error, user) in
            if let user = user {
                callback(nil,user.friends?.allObjects as? [PetUser])
            }else{
                callback(PetError.PetNotFoundInDataBase, nil)
            }
        })
    }


































}
