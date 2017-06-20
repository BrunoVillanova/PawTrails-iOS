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
        
        DataManager.Instance.getPets { (error, pets) in
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
    
    func removePet(by id:Int, _ callback: @escaping (()->())) {
        DataManager.Instance.removePetDB(Int16(id)) { (error) in
            if let error = error {
                debugPrint(error)
            }
            callback()
        }
    }
    
    func addSharedUser(with data: [String:Any], for id: Int, _ callback: @escaping (()->())) {
        DataManager.Instance.addSharedUserDB(with: data, to: Int16(id)) { (error, users) in
            if error != nil || users == nil {
                debugPrint(error ?? "no error", users ?? "no pet users")
            }
            callback()
        }
    }
    
    func removeSharedUser(with id: Int, from petId: Int, _ callback: @escaping (()->())) {
        
        DataManager.Instance.removeSharedUserDB(id: Int16(id), from: Int16(petId)) { (error) in
            if error != nil {
                debugPrint(error ?? "no error")
            }
            callback()
        }
    }
    
    
}
