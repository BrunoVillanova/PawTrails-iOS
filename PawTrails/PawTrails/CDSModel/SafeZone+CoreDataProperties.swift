//
//  SafeZone+CoreDataProperties.swift
//  PawTrails
//
//  Created by Marc Perello on 16/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import CoreData


extension SafeZone {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SafeZone> {
        return NSFetchRequest<SafeZone>(entityName: "SafeZone")
    }

    @NSManaged public var id: Int16
    @NSManaged public var name: String?
    @NSManaged public var preview: Data?
    @NSManaged public var shape: String?
    @NSManaged public var pet: Pet?
    @NSManaged public var point: NSOrderedSet?

}

// MARK: Generated accessors for point
extension SafeZone {

    @objc(insertObject:inPointAtIndex:)
    @NSManaged public func insertIntoPoint(_ value: Point, at idx: Int)

    @objc(removeObjectFromPointAtIndex:)
    @NSManaged public func removeFromPoint(at idx: Int)

    @objc(insertPoint:atIndexes:)
    @NSManaged public func insertIntoPoint(_ values: [Point], at indexes: NSIndexSet)

    @objc(removePointAtIndexes:)
    @NSManaged public func removeFromPoint(at indexes: NSIndexSet)

    @objc(replaceObjectInPointAtIndex:withObject:)
    @NSManaged public func replacePoint(at idx: Int, with value: Point)

    @objc(replacePointAtIndexes:withPoint:)
    @NSManaged public func replacePoint(at indexes: NSIndexSet, with values: [Point])

    @objc(addPointObject:)
    @NSManaged public func addToPoint(_ value: Point)

    @objc(removePointObject:)
    @NSManaged public func removeFromPoint(_ value: Point)

    @objc(addPoint:)
    @NSManaged public func addToPoint(_ values: NSOrderedSet)

    @objc(removePoint:)
    @NSManaged public func removeFromPoint(_ values: NSOrderedSet)

}
