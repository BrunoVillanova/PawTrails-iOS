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
                debugPrint("Pets Loaded")
                if let callback = callback {
                    callback(pets)
                }
                NotificationManager.Instance.postPetListUpdates(with: pets)
            }else{
                debugPrint("Error loading Pets")
            }
        }
        
    }
    
}
