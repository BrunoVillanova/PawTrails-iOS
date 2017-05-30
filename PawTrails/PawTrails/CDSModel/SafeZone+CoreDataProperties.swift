//
//  SafeZone+CoreDataProperties.swift
//  PawTrails
//
//  Created by Marc Perello on 17/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import CoreData


extension SafeZone {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SafeZone> {
        return NSFetchRequest<SafeZone>(entityName: "SafeZone")
    }

    @NSManaged public var name: String?
    @NSManaged public var address: String?
    @NSManaged public var preview: Data?
    @NSManaged public var shape: Int16
    @NSManaged public var id: Int16
    @NSManaged public var active: Bool
    @NSManaged public var point1: Point?
    @NSManaged public var point2: Point?
    @NSManaged public var pet: Pet?

}

// MARK: Generated accessors for pet
extension SafeZone {

    @objc(addPetObject:)
    @NSManaged public func addToPet(_ value: Pet)

    @objc(removePetObject:)
    @NSManaged public func removeFromPet(_ value: Pet)

    @objc(addPet:)
    @NSManaged public func addToPet(_ values: NSSet)

    @objc(removePet:)
    @NSManaged public func removeFromPet(_ values: NSSet)

}
