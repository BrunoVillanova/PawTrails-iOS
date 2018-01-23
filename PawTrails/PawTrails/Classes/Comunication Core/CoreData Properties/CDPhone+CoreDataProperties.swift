//
//  CDPhone+CoreDataProperties.swift
//  
//
//  Created by Marc Perello on 26/06/2017.
//
//

import Foundation
import CoreData


extension CDPhone {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDPhone> {
        return NSFetchRequest<CDPhone>(entityName: "CDPhone")
    }

    @NSManaged public var country_code: String?
    @NSManaged public var number: String?
    @NSManaged public var user: CDUser?

}
