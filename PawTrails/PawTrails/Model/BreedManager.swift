//
//  BreedManager.swift
//  PawTrails
//
//  Created by Marc Perello on 25/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

typealias breedCallback = (_ error:BreedError?, _ breeds:[Breed]?) -> Void

class BreedManager {
    
    static func get(for type:Type, callback: @escaping breedCallback){
        
        if type != .other {
            
            let call: APICallType = type == .cat ? .catBreeds : .dogBreeds
            
        APIManager.Instance.perform(call: call, completition: { (error, data) in
            if let error = error {
                // shit
                print(error)
            }else if let data = data {
                var breeds = [Breed]()
                for (key,value) in data {
                    var record = [String:Any]()
                    record["type"] = type.rawValue
                    record["id"] = key
                    record["name"] = value
                    do {
                        if let breed = try CoreDataManager.Instance.upsert("Breed", with: record, withRestriction: ["type", "id"]) as? Breed {
                            breeds.append(breed)
                        }
                    } catch {
                        callback(nil, nil)
                    }
                }
                breeds.sort(by: { (b1, b2) -> Bool in b1.name! < b2.name! })
                callback(nil, breeds)
            }
        })
            
        }
    }
    
    static func retrieve(for type:Type, callback: @escaping breedCallback) {
        if let breeds =  CoreDataManager.Instance.retrieve("Breed", with: NSPredicate("type", .equal, type.rawValue), sortedBy: [NSSortDescriptor.init(key: "name", ascending: true)]) as? [Breed] {
            callback(nil, breeds)
        }else{
            callback(BreedError.BreedNotFoundInDataBase, nil)
        }
    }
    
}
