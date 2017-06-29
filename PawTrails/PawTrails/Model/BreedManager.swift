////
////  BreedManager.swift
////  PawTrails
////
////  Created by Marc Perello on 25/04/2017.
////  Copyright © 2017 AttitudeTech. All rights reserved.
////
//
//import Foundation
//
//typealias breedsCallback = ((_ error:DataManagerError?, _ breeds:[Breed]?) -> Void)
//typealias breedCallback = (_ error:DataManagerError?, _ breed:Breed?) -> Void
//
//class BreedManager {
//    
//    static func upsert(_ data: [String:Any], for type:Type, callback: breedsCallback? = nil){
//        
//        if let breedsData = data["breeds"] as? [[String:Any]] {
//            do {
//                for var breedData in breedsData {
//                    
//                    if let id = breedData.tryCastInteger(for: "id") {
//
//                        if let breed = try CoreDataManager.Instance.upsert("Breed", with: ["id":id, "type":type.rawValue], withRestriction: ["id","type"]) as? Breed {
//                            
//                            breed.type = type.rawValue
//                            breed.name = breedData["name"] as? String
//                            try CoreDataManager.Instance.save()
//                        }
//                    }
//                }
//            } catch {
//                debugPrint(error)
//                if let callback = callback { callback(DataManagerError(error: error), nil)}
//                return
//            }
//            if let callback = callback { retrieve(for: type, callback: callback) }
//        }else if let callback = callback {
//            callback(DataManagerError.init(responseError: ResponseError.NotFound), nil)
//        }
//    }
//
//    static func retrieve(for type:Type, callback: breedsCallback? = nil) {
//        if let breeds =  CoreDataManager.Instance.retrieve("Breed", with: NSPredicate("type", .equal, type.rawValue), sortedBy: [NSSortDescriptor.init(key: "name", ascending: true)]) as? [Breed] {
//            if let callback = callback { callback(nil, breeds) }
//        }else if let callback = callback {
//            callback(DataManagerError(DBError: DatabaseError.NotFound), nil)
//        }
//    }
//    
//    static func retrieve(for type:Type, breedId: Int, callback: @escaping breedCallback) {
//        if let breeds =  CoreDataManager.Instance.retrieve("Breed", with: NSPredicate("type", .equal, type.rawValue).and("id", .equal, breedId), sortedBy: [NSSortDescriptor.init(key: "name", ascending: true)]) as? [Breed] {
//            if breeds.count == 1 {
//                callback(nil, breeds.first)
//            }else{
//                callback(DataManagerError(DBError: DatabaseError.DuplicatedEntry), nil)
//            }
//        }else{
//            DataManager.Instance.loadBreeds(for: type, callback: { (error, breeds) in
//                if error == nil, let breeds = breeds {
//                    callback(nil, breeds.first(where: { $0.id == Int(breedId) && $0.type == type.rawValue}))
//                }else{
//                    callback(DataManagerError(DBError: DatabaseError.NotFound), nil)
//                }
//            })
//        }
//    }
//    
//    static func remove(for type:Type) {
//        do {
//            try CoreDataManager.Instance.delete(entity: "Breed", withPredicate: NSPredicate("type", .equal, type.rawValue))
//        } catch {
//            debugPrint(error)
//        }
//    }
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//}
