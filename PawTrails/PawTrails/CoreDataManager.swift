//
//  CoreDataManager.swift
//  PawTrails
//
//  Created by Marc Perello on 13/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import CoreData

enum Entity: String {
    case address = "CDAddress"
    case breed = "CDBreed"
    case countryCode = "CDCountryCode"
    case pet = "CDPet"
    case petUser = "CDPetUser"
    case phone = "CDPhone"
    case safeZone = "CDSafeZone"
    case user = "CDUser"
    
    static let allValues:[Entity] = [address, breed, countryCode, pet, petUser, phone, safeZone, user]
}


/// The `CoreDataManager` simplifies the use of **CoreData**
class CoreDataManager {
    
    static let instance = CoreDataManager()
    
    
    /// Retrieves the entities requested following the criteria defined by the *optional* predicate.
    ///
    /// - Parameters:
    ///   - entity: Name of the entity to request.
    ///   - predicate: *Optional* predicate to filter fetch.
    ///   - sortedBy: *Optional* sorts the results of the fetch.
    ///   - callback: An array with **more than one element** or *nil*.
    func retrieve(_ entity:Entity, with predicate: NSPredicate? = nil, sortedBy: [NSSortDescriptor]? = nil, callback: @escaping ([NSManagedObject]?)-> Void) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortedBy
        
        do {
            let data = try Storage.Instance.context.fetch(fetchRequest)
            
            callback(data.count > 0 ? data as? [NSManagedObject] : nil)
            return
            
            
        } catch {
            debugPrint("CDM retrieve entity: \(entity) withPredicate: \(String(describing: predicate)) error: \(error)")
        }
        callback(nil)
    }
    
    /// Store the given data into the entity.
    ///
    /// - Parameters:
    ///   - entity: Name of the entity to save.
    ///   - data: Dictionary with information to store.
    ///   - callback: The saved object.
    func store(_ entity:Entity, with data:[String:Any], callback: @escaping (NSManagedObject?)-> Void) {
        
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entity.rawValue, in: Storage.Instance.context) else {
            let error =  NSError(domain: "CDM store entity \(entity)", code: DatabaseErrorType.InternalInconsistencyException.rawValue, userInfo: data)
            debugPrint(error)
            callback(nil)
            return
        }
        //        Storage.Instance.context.perform {
        let object = NSManagedObject(entity: entityDescription, insertInto: Storage.Instance.context)
        
        for (key,value) in data {
            if object.keys.contains(key) { object.setValue(value, forKey: key) }
        }
        
        self.save(callback: { (error) in
            if let error = error {
                debugPrint(error)
                callback(nil)
            }else{
                callback(object)
            }
        })
        //        }
    }
    
    /// Updates the current element or insert it as a new one if that one does not exists.
    ///
    /// - Parameters:
    ///   - entity: Name of the entity to upsert.
    ///   - data: Dictionary with information to upsert.
    ///   - idKey: Identify the element, it **must** be the same in the `Local Storage` and in the `Dictionary` provided.
    ///   - callback: The upserted object.
    func upsert(_ entity:Entity, with data:[String:Any], withId idKey:String = "id", callback: @escaping (NSManagedObject?)-> Void) {
        
        //Check input id
        guard let id = data[idKey] else {
            let error = NSError(domain: "CDM upsert entity \(entity) failed reading input data \(idKey)", code: DatabaseErrorType.IdNotFound.rawValue, userInfo: ["data":data])
            debugPrint(error)
            callback(nil)
            return
        }
        
        let predicate = NSPredicate(idKey, NSPredicateOperation.equal, id)
        
        upsert(entity, withPredicate: predicate, withData: data, callback: callback)
    }
    
    /// Updates the current element or insert it as a new one if that one does not exists.
    ///
    /// - Parameters:
    ///   - entity: Name of the entity to upsert.
    ///   - data: Dictionary with information to upsert.
    ///   - restrictions: Identify the element, it **must** be the same in the `Local Storage` and in the `Dictionary` provided.
    ///   - callback: The upserted object.
    func upsert(_ entity:Entity, with data:[String:Any], withRestriction restrictions:[String], callback: @escaping (NSManagedObject?)-> Void) {
        
        if restrictions.count == 0 {
            upsert(entity, with: data, callback: callback)
        }else if restrictions.count == 1 {
            upsert(entity, with: data, withId: restrictions[0], callback: callback)
        }else if let predicate = buildPredicate(with: restrictions, from: data) {
            upsert(entity, withPredicate: predicate, withData: data, callback: callback)
        }else {
            callback(nil)
        }
        
        
    }
    
    private func buildPredicate(with restrictions:[String], from data:[String:Any]) -> NSPredicate? {
        var predicate: NSPredicate?
        
        //Check input restrictions
        for restriction in restrictions {
            
            if let value = data[restriction] {
                
                if predicate == nil {
                    predicate = NSPredicate(restriction, .equal, value)
                }else{
                    predicate = predicate?.and(restriction, .equal, value)
                }
                
            }else{
                let error = NSError(domain: "CDM buildPredicate failed reading input data \(restriction)", code: DatabaseErrorType.IdNotFound.rawValue, userInfo: ["data":data])
                debugPrint(error)
                return nil
            }
        }
        
        return predicate
    }
    
    private func upsert(_ entity:Entity, withPredicate predicate: NSPredicate?, withData data: [String:Any], callback: @escaping (NSManagedObject?)-> Void) {
        
        
        retrieve(entity, with: predicate) { (objects) in
            //Update
            if let object = objects?.first {
                //
                //                for key in object.keys {
                //                    if !(object.value(forKey: key)  is NSManagedObject) && !(object.value(forKey: key)  is NSData)  {
                //                        object.setValue(data[key], forKey: key)
                //                    }
                //                }
                //                try save(entity, userInfo: data)
                callback(object)
                //Create
            }else{
                self.store(entity, with: data, callback: callback)
            }
        }
    }
    
    /// Deletes the entity specifies following the criteria defined by the predicate.
    ///
    /// - Parameters:
    ///   - entity: Name of the entity to delete.
    ///   - predicate: *Optional* predicate to filter fetch.
    func delete(entity:Entity, withPredicate predicate: NSPredicate? = nil) {
        
        retrieve(entity, with: predicate) { (results) in
            
            if let results = results {
                //                Storage.Instance.context.perform {
                for i in results {
                    Storage.Instance.context.delete(i)
                }
                self.save(callback: { (error) in
                    if let error = error {
                        debugPrint(error)
                    }
                })
                //                }
            }else{
                let error = NSError(domain: "Object to delete not found", code: DatabaseErrorType.ObjectNotFound.rawValue, userInfo: ["entity":entity, "predicate":predicate.debugDescription])
                debugPrint(error)
            }
        }
    }
    
    func deleteAll() {
        
        for i in Entity.allValues.map({ $0.rawValue }) {
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: i)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            //            Storage.Instance.context.perform {
            do {
                try Storage.Instance.context.execute(deleteRequest)
                self.save(callback: { (error) in
                    if let error = error {
                        debugPrint(error)
                    }
                })
            } catch {
                debugPrint(error)
            }
            //            }
        }
    }
    
    /// Attempts to commit unsaved changes to registered objects.
    ///
    func save(_ entity:Entity? = nil, userInfo: [AnyHashable : Any]? = nil, callback: @escaping (DatabaseError?)->Void) {

        let status = Storage.Instance.save()
        if status == .rolledBack {
            callback(DatabaseError(type: .NotSavedProperly, entity: entity, action: .save, error: nil))
        }else{
            callback(nil)
        }
    }
    
}

/// NSPersistentStoreCoordinator extension
extension NSPersistentStoreCoordinator {
    
    /// NSPersistentStoreCoordinator error types
    public enum CoordinatorError: Error {
        /// .momd file not found
        case modelFileNotFound
        /// NSManagedObjectModel creation fail
        case modelCreationError
        /// Gettings document directory fail
        case storePathNotFound
    }
    
    /// Return NSPersistentStoreCoordinator object
    static func coordinator(name: String) throws -> NSPersistentStoreCoordinator? {
        
        guard let modelURL = Bundle.main.url(forResource: name, withExtension: "momd") else {
            throw CoordinatorError.modelFileNotFound
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw CoordinatorError.modelCreationError
        }
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            throw CoordinatorError.storePathNotFound
        }
        
        do {
            let url = documents.appendingPathComponent("\(name).sqlite")
            let options = [ NSMigratePersistentStoresAutomaticallyOption : true,
                            NSInferMappingModelAutomaticallyOption : true ]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            throw error
        }
        
        return coordinator
    }
}

fileprivate struct Storage {
    
    static var Instance = Storage()
    
    @available(iOS 10.0, *)
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PawTrails")
        container.loadPersistentStores { (storeDescription, error) in
            
            guard error == nil else {
                print("CoreData: Unresolved error \(String(describing: error))")
                return
            }
        }
        return container
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        do {
            return try NSPersistentStoreCoordinator.coordinator(name: "PawTrails")
        } catch {
            print("CoreData: Unresolved error \(error)")
        }
        return nil
    }()
    
    private lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: Public methods
    
    enum SaveStatus {
        case saved, rolledBack, hasNoChanges
    }
    
    var context: NSManagedObjectContext {
        mutating get {
            if #available(iOS 10.0, *) {
                return persistentContainer.viewContext
            } else {
                return managedObjectContext
            }
        }
    }
    
    mutating func save() -> SaveStatus {
        if context.hasChanges {
            do {
                try context.save()
                return .saved
            } catch {
                debugPrint("Couldn't Save", error)
                context.rollback()
                return .rolledBack
            }
        }
        return .hasNoChanges
    }
    
}
