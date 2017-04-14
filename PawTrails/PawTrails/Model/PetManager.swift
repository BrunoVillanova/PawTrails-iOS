//
//  UserManager.swift
//  PawTrails
//
//  Created by Marc Perello on 21/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//


typealias petCallback = (_ error:Int?, _ pet:Pet?) -> Void
typealias petsCallback = (_ error:Int?, _ pet:[Pet]?) -> Void
typealias petTrackingCallback = (_ location:(Double, Double)) -> Void

import Foundation

class PetManager {
    
    
    static func upsertPet(_ data: [String:Any]) {
        
        do {
            if (try CoreDataManager.Instance.upsert("Pet", with: data.filtered(by:["last_location"])) as? Pet) != nil {
                try CoreDataManager.Instance.save()
            }
        } catch {
            //
        }
    }
    
    static func getPet(id:Int, _ callback:petCallback) {
        
//        if let results = CoreDataManager.Instance.retrieve("Pet", with: NSPredicate("id", .equal, id)) as? [Pet] {
//            if results.count > 1 {
//                callback(UserError.MoreThenOneUser.rawValue, nil)
//            }else{
//                callback(nil, results.first!)
//            }
//        }else{
//            callback(UserError.NoUserFound.rawValue, nil)
//        }
    }

    static func removePet(id: Int) -> Bool {
        try? CoreDataManager.Instance.delete(entity: "pet", withPredicate: NSPredicate("id", .equal, id))
        return true
    }
}
