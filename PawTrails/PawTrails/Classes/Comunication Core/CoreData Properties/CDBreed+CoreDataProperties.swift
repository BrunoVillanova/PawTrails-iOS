//
//  CDBreed+CoreDataProperties.swift
//  
//
//  Created by Marc Perello on 26/06/2017.
//
//

import Foundation
import CoreData


extension CDBreed {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDBreed> {
        return NSFetchRequest<CDBreed>(entityName: "CDBreed")
    }

    @NSManaged public var id: Int16
    @NSManaged public var name: String?
    @NSManaged public var type: Int16
    @NSManaged public var petFirst: NSSet?
    @NSManaged public var petSecond: NSSet?

}

// MARK: Generated accessors for petFirst
extension CDBreed {

    @objc(addPetFirstObject:)
    @NSManaged public func addToPetFirst(_ value: CDPet)

    @objc(removePetFirstObject:)
    @NSManaged public func removeFromPetFirst(_ value: CDPet)

    @objc(addPetFirst:)
    @NSManaged public func addToPetFirst(_ values: NSSet)

    @objc(removePetFirst:)
    @NSManaged public func removeFromPetFirst(_ values: NSSet)

}

// MARK: Generated accessors for petSecond
extension CDBreed {

    @objc(addPetSecondObject:)
    @NSManaged public func addToPetSecond(_ value: CDPet)

    @objc(removePetSecondObject:)
    @NSManaged public func removeFromPetSecond(_ value: CDPet)

    @objc(addPetSecond:)
    @NSManaged public func addToPetSecond(_ values: NSSet)

    @objc(removePetSecond:)
    @NSManaged public func removeFromPetSecond(_ values: NSSet)

}
