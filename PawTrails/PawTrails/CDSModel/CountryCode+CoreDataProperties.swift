//
//  CountryCode+CoreDataProperties.swift
//  PawTrails
//
//  Created by Marc Perello on 16/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import CoreData


extension CountryCode {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CountryCode> {
        return NSFetchRequest<CountryCode>(entityName: "CountryCode")
    }

    @NSManaged public var code: String?
    @NSManaged public var name: String?
    @NSManaged public var shortname: String?

}
