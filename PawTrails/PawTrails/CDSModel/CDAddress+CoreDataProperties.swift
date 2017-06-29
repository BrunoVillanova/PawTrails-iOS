//
//  CDAddress+CoreDataProperties.swift
//  
//
//  Created by Marc Perello on 26/06/2017.
//
//

import Foundation
import CoreData


extension CDAddress {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDAddress> {
        return NSFetchRequest<CDAddress>(entityName: "CDAddress")
    }

    @NSManaged public var city: String?
    @NSManaged public var country: String?
    @NSManaged public var line0: String?
    @NSManaged public var line1: String?
    @NSManaged public var line2: String?
    @NSManaged public var postal_code: String?
    @NSManaged public var state: String?
    @NSManaged public var user: CDUser?

}
