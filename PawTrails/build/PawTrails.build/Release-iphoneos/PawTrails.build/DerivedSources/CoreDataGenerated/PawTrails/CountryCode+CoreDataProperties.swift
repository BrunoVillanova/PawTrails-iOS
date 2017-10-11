//
//  CountryCode+CoreDataProperties.swift
//  
//
//  Created by Marc Perello on 14/04/2017.
//
//  This file was automatically generated and should not be edited.
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
