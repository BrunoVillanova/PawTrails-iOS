//
//  PetUser+CoreDataProperties.swift
//  PawTrails
//
//  Created by Marc Perello on 16/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import CoreData


extension PetUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PetUser> {
        return NSFetchRequest<PetUser>(entityName: "PetUser")
    }

    @NSManaged public var email: String?
    @NSManaged public var id: Int16
    @NSManaged public var image: Data?
    @NSManaged public var imageURL: String?
    @NSManaged public var isOwner: Bool
    @NSManaged public var name: String?
    @NSManaged public var surname: String?
    @NSManaged public var petUsers: NSSet?
    @NSManaged public var user: User?

}

// MARK: Generated accessors for petUsers
extension PetUser {

    @objc(addPetUsersObject:)
    @NSManaged public func addToPetUsers(_ value: Pet)

    @objc(removePetUsersObject:)
    @NSManaged public func removeFromPetUsers(_ value: Pet)

    @objc(addPetUsers:)
    @NSManaged public func addToPetUsers(_ values: NSSet)

    @objc(removePetUsers:)
    @NSManaged public func removeFromPetUsers(_ values: NSSet)

}
