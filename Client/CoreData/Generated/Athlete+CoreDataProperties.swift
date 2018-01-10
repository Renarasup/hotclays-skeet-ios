//
//  Athlete+CoreDataProperties.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/5/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//
//

import Foundation
import CoreData


extension Athlete {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Athlete> {
        return NSFetchRequest<Athlete>(entityName: "Athlete")
    }

    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var defaultGauge: Int16
    @NSManaged public var defaultYardage: Int16
    @NSManaged public var isOnTeam: Bool
    @NSManaged public var sheets: NSSet?

}

// MARK: Generated accessors for sheets
extension Athlete {

    @objc(addSheetsObject:)
    @NSManaged public func addToSheets(_ value: Sheet)

    @objc(removeSheetsObject:)
    @NSManaged public func removeFromSheets(_ value: Sheet)

    @objc(addSheets:)
    @NSManaged public func addToSheets(_ values: NSSet)

    @objc(removeSheets:)
    @NSManaged public func removeFromSheets(_ values: NSSet)

}
