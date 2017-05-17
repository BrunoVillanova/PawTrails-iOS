//
//  Point+CoreDataProperties.swift
//  PawTrails
//
//  Created by Marc Perello on 16/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import CoreData


extension Point {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Point> {
        return NSFetchRequest<Point>(entityName: "Point")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var locations: NSSet?
    @NSManaged public var safezones: NSSet?

}

// MARK: Generated accessors for locations
extension Point {

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: Location)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: Location)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSSet)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSSet)

}

// MARK: Generated accessors for safezones
extension Point {

    @objc(addSafezonesObject:)
    @NSManaged public func addToSafezones(_ value: SafeZone)

    @objc(removeSafezonesObject:)
    @NSManaged public func removeFromSafezones(_ value: SafeZone)

    @objc(addSafezones:)
    @NSManaged public func addToSafezones(_ values: NSSet)

    @objc(removeSafezones:)
    @NSManaged public func removeFromSafezones(_ values: NSSet)

}
