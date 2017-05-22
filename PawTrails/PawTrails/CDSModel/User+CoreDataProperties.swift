//
//  User+CoreDataProperties.swift
//  PawTrails
//
//  Created by Marc Perello on 16/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var birthday: Date?
    @NSManaged public var email: String?
    @NSManaged public var gender: Int16
    @NSManaged public var id: Int16
    @NSManaged public var image: Data?
    @NSManaged public var imageURL: String?
    @NSManaged public var name: String?
    @NSManaged public var notification: Bool
    @NSManaged public var surname: String?
    @NSManaged public var address: Address?
    @NSManaged public var friends: NSSet?
    @NSManaged public var phone: Phone?

}

// MARK: Generated accessors for friends
extension User {

    @objc(addFriendsObject:)
    @NSManaged public func addToFriends(_ value: PetUser)

    @objc(removeFriendsObject:)
    @NSManaged public func removeFromFriends(_ value: PetUser)

    @objc(addFriends:)
    @NSManaged public func addToFriends(_ values: NSSet)

    @objc(removeFriends:)
    @NSManaged public func removeFromFriends(_ values: NSSet)

}
