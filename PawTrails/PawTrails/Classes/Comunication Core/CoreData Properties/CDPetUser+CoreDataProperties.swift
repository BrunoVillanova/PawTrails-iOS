//
//  CDPetUser+CoreDataProperties.swift
//  
//
//  Created by Marc Perello on 26/06/2017.
//
//

import Foundation
import CoreData


extension CDPetUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDPetUser> {
        return NSFetchRequest<CDPetUser>(entityName: "CDPetUser")
    }

    @NSManaged public var email: String?
    @NSManaged public var id: Int16
    @NSManaged public var image: Data?
    @NSManaged public var imageURL: String?
    @NSManaged public var isOwner: Bool
    @NSManaged public var name: String?
    @NSManaged public var surname: String?
    @NSManaged public var petUsers: NSSet?
    @NSManaged public var user: NSSet?

}

// MARK: Generated accessors for petUsers
extension CDPetUser {

    @objc(addPetUsersObject:)
    @NSManaged public func addToPetUsers(_ value: CDPet)

    @objc(removePetUsersObject:)
    @NSManaged public func removeFromPetUsers(_ value: CDPet)

    @objc(addPetUsers:)
    @NSManaged public func addToPetUsers(_ values: NSSet)

    @objc(removePetUsers:)
    @NSManaged public func removeFromPetUsers(_ values: NSSet)

}

// MARK: Generated accessors for user
extension CDPetUser {

    @objc(addUserObject:)
    @NSManaged public func addToUser(_ value: CDUser)

    @objc(removeUserObject:)
    @NSManaged public func removeFromUser(_ value: CDUser)

    @objc(addUser:)
    @NSManaged public func addToUser(_ values: NSSet)

    @objc(removeUser:)
    @NSManaged public func removeFromUser(_ values: NSSet)

}
