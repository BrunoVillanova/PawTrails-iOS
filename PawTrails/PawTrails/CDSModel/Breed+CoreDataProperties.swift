//
//  Breed+CoreDataProperties.swift
//  PawTrails
//
//  Created by Marc Perello on 16/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import CoreData


extension Breed {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Breed> {
        return NSFetchRequest<Breed>(entityName: "Breed")
    }

    @NSManaged public var id: Int16
    @NSManaged public var name: String?
    @NSManaged public var type: Int16
    @NSManaged public var petFirst: Pet?
    @NSManaged public var petSecond: Pet?

}
