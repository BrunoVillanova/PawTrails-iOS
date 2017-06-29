//
//  CDCountryCode+CoreDataProperties.swift
//  
//
//  Created by Marc Perello on 26/06/2017.
//
//

import Foundation
import CoreData


extension CDCountryCode {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDCountryCode> {
        return NSFetchRequest<CDCountryCode>(entityName: "CDCountryCode")
    }

    @NSManaged public var code: String?
    @NSManaged public var name: String?
    @NSManaged public var shortname: String?

}
