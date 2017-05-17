//
//  BreedManager.swift
//  PawTrails
//
//  Created by Marc Perello on 25/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

typealias breedsCallback = ((_ error:BreedError?, _ breeds:[Breed]?) -> Void)
typealias breedCallback = (_ error:BreedError?, _ breed:Breed?) -> Void

class BreedManager {
    
    static func upsert(_ data: [String:Any], for type:Type, callback: breedsCallback? = nil){
        
        if let breedsData = data["breeds"] as? [[String:Any]] {
            do {
                for var breedData in breedsData {
                    
                    if let id = breedData.tryCastInteger(for: "id") {
                        
                        if let breed = try CoreDataManager.Instance.upsert("Breed", with: ["id":id]) as? Breed {
                            
                            breed.type = type.rawValue
                            breed.name = breedData["name"] as? String
                        }
                    }
                    
                }
            } catch {
                print(error)
                if let callback = callback { callback(BreedError.MoreThenOneBreed, nil) }
            }
            retrieve(for: type, callback: callback)
        }
    }


    static func retrieve(for type:Type, callback: breedsCallback? = nil) {
        if let breeds =  CoreDataManager.Instance.retrieve("Breed", with: NSPredicate("type", .equal, type.rawValue), sortedBy: [NSSortDescriptor.init(key: "name", ascending: true)]) as? [Breed] {
            if let callback = callback {
                callback(nil, breeds)
            }
        }else if let callback = callback {
            callback(BreedError.BreedNotFoundInDataBase, nil)
        }
    }
    
    static func retrieve(for type:Type, breedId: String) -> Breed? {
        if let breeds =  CoreDataManager.Instance.retrieve("Breed", with: NSPredicate("type", .equal, type.rawValue).and("id", .equal, breedId), sortedBy: [NSSortDescriptor.init(key: "name", ascending: true)]) as? [Breed] {
            if breeds.count == 1 {
                return breeds.first
            }
        }
        return nil
    }
    
    static func remove(for type:Type) {
        do {
            try CoreDataManager.Instance.delete(entity: "Breed", withPredicate: NSPredicate("type", .equal, type.rawValue))
        } catch {
            debugPrint(error)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
