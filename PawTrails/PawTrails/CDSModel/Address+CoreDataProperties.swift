//
//  Address+CoreDataProperties.swift
//  PawTrails
//
//  Created by Marc Perello on 16/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import CoreData


extension Address {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Address> {
        return NSFetchRequest<Address>(entityName: "Address")
    }

    @NSManaged public var city: String?
    @NSManaged public var country: String?
    @NSManaged public var line0: String?
    @NSManaged public var line1: String?
    @NSManaged public var line2: String?
    @NSManaged public var postal_code: String?
    @NSManaged public var state: String?
    @NSManaged public var user: User?

}
