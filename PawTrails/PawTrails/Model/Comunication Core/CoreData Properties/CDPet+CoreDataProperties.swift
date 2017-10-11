//
//  CDPet+CoreDataProperties.swift
//  
//
//  Created by Marc Perello on 26/06/2017.
//
//

import Foundation
import CoreData


extension CDPet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDPet> {
        return NSFetchRequest<CDPet>(entityName: "CDPet")
    }

    @NSManaged public var birthday: Date?
    @NSManaged public var breed_descr: String?
    @NSManaged public var deviceCode: String?
    @NSManaged public var gender: Int16
    @NSManaged public var id: Int16
    @NSManaged public var image: Data?
    @NSManaged public var imageURL: String?
    @NSManaged public var isOwner: Bool
    @NSManaged public var name: String?
    @NSManaged public var neutered: Bool
    @NSManaged public var tracking: Bool
    @NSManaged public var type: Int16
    @NSManaged public var type_descr: String?
    @NSManaged public var weight: Double
    @NSManaged public var firstBreed: CDBreed?
    @NSManaged public var safezones: NSSet?
    @NSManaged public var secondBreed: CDBreed?
    @NSManaged public var users: NSSet?

}

// MARK: Generated accessors for safezones
extension CDPet {

    @objc(addSafezonesObject:)
    @NSManaged public func addToSafezones(_ value: CDSafeZone)

    @objc(removeSafezonesObject:)
    @NSManaged public func removeFromSafezones(_ value: CDSafeZone)

    @objc(addSafezones:)
    @NSManaged public func addToSafezones(_ values: NSSet)

    @objc(removeSafezones:)
    @NSManaged public func removeFromSafezones(_ values: NSSet)

}

// MARK: Generated accessors for users
extension CDPet {

    @objc(addUsersObject:)
    @NSManaged public func addToUsers(_ value: CDPetUser)

    @objc(removeUsersObject:)
    @NSManaged public func removeFromUsers(_ value: CDPetUser)

    @objc(addUsers:)
    @NSManaged public func addToUsers(_ values: NSSet)

    @objc(removeUsers:)
    @NSManaged public func removeFromUsers(_ values: NSSet)

}
