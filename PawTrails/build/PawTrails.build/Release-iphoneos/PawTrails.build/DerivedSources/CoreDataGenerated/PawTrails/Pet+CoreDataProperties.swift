//
//  Pet+CoreDataProperties.swift
//  
//
//  Created by Marc Perello on 14/04/2017.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Pet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pet> {
        return NSFetchRequest<Pet>(entityName: "Pet")
    }

    @NSManaged public var gender: String?
    @NSManaged public var id: String?
    @NSManaged public var image: NSData?
    @NSManaged public var imageURL: String?
    @NSManaged public var name: String?
    @NSManaged public var tracking: Bool
    @NSManaged public var last_location: Location?

}
