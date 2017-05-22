//
//  Pet+CoreDataProperties.swift
//  PawTrails
//
//  Created by Marc Perello on 16/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import CoreData


extension Pet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pet> {
        return NSFetchRequest<Pet>(entityName: "Pet")
    }

    @NSManaged public var birthday: Date?
    @NSManaged public var breed_descr: String?
    @NSManaged public var deviceCode: String?
    @NSManaged public var gender: Int16
    @NSManaged public var id: Int16
    @NSManaged public var image: Data?
    @NSManaged public var imageURL: String?
    @NSManaged public var name: String?
    @NSManaged public var neutered: Bool
    @NSManaged public var tracking: Bool
    @NSManaged public var type: Int16
    @NSManaged public var type_descr: String?
    @NSManaged public var weight: Double
    @NSManaged public var isOwner: Bool
    @NSManaged public var firstBreed: Breed?
    @NSManaged public var safezones: NSSet?
    @NSManaged public var secondBreed: Breed?
    @NSManaged public var users: NSSet?

}

// MARK: Generated accessors for safezones
extension Pet {

    @objc(addSafezonesObject:)
    @NSManaged public func addToSafezones(_ value: SafeZone)

    @objc(removeSafezonesObject:)
    @NSManaged public func removeFromSafezones(_ value: SafeZone)

    @objc(addSafezones:)
    @NSManaged public func addToSafezones(_ values: NSSet)

    @objc(removeSafezones:)
    @NSManaged public func removeFromSafezones(_ values: NSSet)

}

// MARK: Generated accessors for users
extension Pet {

    @objc(addUsersObject:)
    @NSManaged public func addToUsers(_ value: PetUser)

    @objc(removeUsersObject:)
    @NSManaged public func removeFromUsers(_ value: PetUser)

    @objc(addUsers:)
    @NSManaged public func addToUsers(_ values: NSSet)

    @objc(removeUsers:)
    @NSManaged public func removeFromUsers(_ values: NSSet)

}
