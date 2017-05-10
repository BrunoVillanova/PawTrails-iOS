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
    
    static func load(for type:Type, callback: breedsCallback? = nil){
        
        if type != .other {
            
            APIManager.Instance.perform(call: .getBreeds, withKey: type.code, completition: { (error, data) in
                if let error = error {
                    // shit
                    debugPrint(error)
                }else if let breedsData = data?["breeds"] as? [[String:Any]] {
                    do {
                        for var breedData in breedsData {
                            
                            breedData["type"] = type.rawValue
                            
                            _ = try CoreDataManager.Instance.upsert("Breed", with: breedData, withRestriction: ["type", "id"])
                            
                        }
                    } catch {
                        if let callback = callback {
                            callback(nil, nil)
                        }
                    }
                    retrieve(for: type, callback: callback)
                }
            })
            
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
    
    static func check() {
//        DispatchQueue.main.sync {
            retrieve(for: .cat) { (error, breeds) in
                if breeds == nil {
                    load(for: .cat, callback: { (error, breeds) in
                        if let breeds = breeds {
                            for i in breeds {
                                debugPrint(i)
                            }
                        }
                    })
                }
            }
            retrieve(for: .dog) { (error, breeds) in
                if breeds == nil {
                    load(for: .dog, callback: { (error, breeds) in
                        if let breeds = breeds {
                            for i in breeds {
                                debugPrint(i)
                            }
                        }
                    })
                }
            }
//        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
