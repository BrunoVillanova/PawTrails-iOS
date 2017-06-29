//
//  UpdateManager.swift
//  PawTrails
//
//  Created by Marc Perello on 08/06/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

class UpdateManager {
    
    static let Instance = UpdateManager()
    
    func loadPetList(_ callback: ((_ pets: [Pet]?)->())? = nil){
        
        DataManager.Instance.loadPets { (error, pets) in
            if error == nil, let pets = pets {

                if let callback = callback {
                    callback(pets)
                }
                NotificationManager.Instance.postPetListUpdates(with: pets)
            }else{
                debugPrint("Error loading Pets")
            }
        }
    }
    
    func addPet(_ data: [String:Any], callback: @escaping (()->())){
//        DataManager.Instance.addPetDB(data) { (error, pet) in
//            if (error != nil) || pet == nil {
//                debugPrint(error ?? "no error")
//            }else{
//                callback()
//            }
//        }
    }
    
    func removePet(by id:Int, _ callback: @escaping (()->())) {
//        DataManager.Instance.removePetDB(Int(id)) { (error) in
//            if let error = error {
//                debugPrint(error)
//            }else{
//                callback()
//            }
//        }
    }
    
    func addSharedUser(with data: [String:Any], for id: Int, _ callback: @escaping (()->())) {
//        DataManager.Instance.addSharedUserDB(with: data, to: Int(id)) { (error, users) in
//            if error != nil || users == nil {
//                debugPrint(error ?? "no error", users ?? "no pet users")
//            }else{
//                callback()
//            }
//        }
    }
    
    func removeSharedUser(with id: Int, from petId: Int, _ callback: @escaping (()->())) {
        
        DataManager.Instance.removeSharedUserDB(id: Int(id), from: Int(petId)) { (error) in
            if let error = error {
                debugPrint(error)
            }else{
                callback()
            }
        }
    }
    
    
}
