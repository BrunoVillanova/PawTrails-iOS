//
//  CDSafeZone+CoreDataProperties.swift
//  
//
//  Created by Marc Perello on 26/06/2017.
//
//

import Foundation
import CoreData


extension CDSafeZone {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDSafeZone> {
        return NSFetchRequest<CDSafeZone>(entityName: "CDSafeZone")
    }

    @NSManaged public var active: Bool
    @NSManaged public var address: String?
    @NSManaged public var id: Int16
    @NSManaged public var name: String?
    @NSManaged public var point1: Point?
    @NSManaged public var point2: Point?
    @NSManaged public var preview: Data?
    @NSManaged public var shape: Int16
    @NSManaged public var pet: CDPet?

}
