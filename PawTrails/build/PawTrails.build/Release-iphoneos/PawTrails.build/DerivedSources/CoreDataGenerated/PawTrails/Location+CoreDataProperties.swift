//
//  Location+CoreDataProperties.swift
//  
//
//  Created by Marc Perello on 14/04/2017.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var datetime: NSDate?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var pet: Pet?

}
