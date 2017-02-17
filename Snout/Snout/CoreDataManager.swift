//
//  CoreDataManager.swift
//  Snout
//
//  Created by Marc Perello on 13/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import CoreData


class CoreDataManager {
    
    static let Instance = CoreDataManager()
    
    private func remove(keys:[String], from data: [String:Any]) -> [String:Any]{
        if keys.count == 0 {
            return data
        }else{
            var out = [String:Any]()
            for (k,v) in data {
                if !keys.contains(k){
                    out[k] = v
                }
            }
            return out
        }
    }
    
    func retrieve(entity:String, withPredicate predicate: NSPredicate? = nil) -> [NSManagedObject]? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.predicate = predicate
        
        do {
            let data = try Storage.Instance.context.fetch(fetchRequest)
            return data.count > 0 ? data as? [NSManagedObject] : nil
            
        } catch {
            debugPrint("CDM get entity: \(entity) withPredicate: \(predicate) error: \(error)")
        }
        return nil
    }
    
    func store(entity:String, withData data:[String:Any], skippedKeys: [String] = []) throws ->  NSManagedObject {
        
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entity, in: Storage.Instance.context) else {
            throw NSError(domain: "CDM store entity \(entity)", code: CoreDataManagerError.InternalInconsistencyException.rawValue, userInfo: data)
        }
        
        let object = NSManagedObject(entity: entityDescription, insertInto: Storage.Instance.context)
        
        for (key,value) in remove(keys: skippedKeys, from: data) {
            object.setValue(value, forKey: key)
        }
        
        if Storage.Instance.save() != Storage.SaveStatus.saved {
            throw NSError(domain: "Not Saved Properly", code: CoreDataManagerError.NotSavedProperly.rawValue, userInfo: data)
        }
        return object
    }
    
    func upsert(entity:String, withData data:[String:Any], withId id:String = "id", skippedKeys: [String] = []) throws -> NSManagedObject {
        
        //Check input id
        guard data[id] != nil else {
            throw NSError(domain: "CDM upsert entity \(entity) failed reading input data \(id)", code: CoreDataManagerError.IdNotFoundInInput.rawValue, userInfo: ["data":data, "skippedkeys":skippedKeys])
        }
        
        //Look for an existing object with id
        if let object = retrieve(entity: entity, withPredicate: NSPredicate(format: "\(id) == \(data[id]!)"))?.first {
            
            for (key,value) in remove(keys: skippedKeys, from: data) {
                if value is NSNull {
                    //
                }else{
                    object.setValue(value, forKey: key)
                }
            }
            
            if Storage.Instance.save() != Storage.SaveStatus.saved {
                throw NSError(domain: "Not Saved Properly", code: CoreDataManagerError.NotSavedProperly.rawValue, userInfo: data)
            }
            return object
        }else{
            return try store(entity: entity, withData: data, skippedKeys: skippedKeys)
        }
    }
    
    func delete(entity: String, withPredicate predicate: NSPredicate? = nil) throws {
        guard let results = retrieve(entity: entity, withPredicate: predicate) else {
            throw NSError(domain: "Object to delete not found", code: CoreDataManagerError.ObjectNotFound.rawValue, userInfo: ["entity":entity, "predicate":predicate.debugDescription])
        }
        
        for i in results {
            Storage.Instance.context.delete(i)
        }
    }
    
    func save() throws {
        if Storage.Instance.save() != Storage.SaveStatus.saved {
            throw NSError(domain: "Not Saved Properly", code: CoreDataManagerError.NotSavedProperly.rawValue)
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
        let container = NSPersistentContainer(name: "Snout")
        container.loadPersistentStores { (storeDescription, error) in
            print("CoreData: Inited \(storeDescription)")
            guard error == nil else {
                print("CoreData: Unresolved error \(error)")
                return
            }
        }
        return container
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        do {
            return try NSPersistentStoreCoordinator.coordinator(name: "Snout")
        } catch {
            print("CoreData: Unresolved error \(error)")
        }
        return nil
    }()
    
    private lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
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
                context.rollback()
                return .rolledBack
            }
        }
        return .hasNoChanges
    }
    
}
