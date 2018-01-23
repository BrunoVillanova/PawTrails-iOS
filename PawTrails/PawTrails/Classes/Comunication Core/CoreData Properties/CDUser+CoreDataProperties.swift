//
//  CDUser+CoreDataProperties.swift
//  
//
//  Created by Marc Perello on 26/06/2017.
//
//

import Foundation
import CoreData


extension CDUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUser> {
        return NSFetchRequest<CDUser>(entityName: "CDUser")
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
    @NSManaged public var address: CDAddress?
    @NSManaged public var friends: NSSet?
    @NSManaged public var phone: CDPhone?

}

// MARK: Generated accessors for friends
extension CDUser {

    @objc(addFriendsObject:)
    @NSManaged public func addToFriends(_ value: CDPetUser)

    @objc(removeFriendsObject:)
    @NSManaged public func removeFromFriends(_ value: CDPetUser)

    @objc(addFriends:)
    @NSManaged public func addToFriends(_ values: NSSet)

    @objc(removeFriends:)
    @NSManaged public func removeFromFriends(_ values: NSSet)

}
