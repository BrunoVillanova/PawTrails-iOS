//
//  User+CoreDataProperties.swift
//  
//
//  Created by Marc Perello on 14/04/2017.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var birthday: NSDate?
    @NSManaged public var email: String?
    @NSManaged public var gender: String?
    @NSManaged public var id: String?
    @NSManaged public var image: NSData?
    @NSManaged public var imageURL: String?
    @NSManaged public var isLocationShared: Bool
    @NSManaged public var name: String?
    @NSManaged public var notification: Bool
    @NSManaged public var socialNetwork: String?
    @NSManaged public var socialNetworkId: String?
    @NSManaged public var surname: String?
    @NSManaged public var address: Address?
    @NSManaged public var phone: Phone?

}
