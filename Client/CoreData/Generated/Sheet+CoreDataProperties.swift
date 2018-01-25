//
//  Sheet+CoreDataProperties.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/25/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//
//

import Foundation
import CoreData


extension Sheet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sheet> {
        return NSFetchRequest<Sheet>(entityName: "Sheet")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var event: String?
    @NSManaged public var field: String?
    @NSManaged public var id: String?
    @NSManaged public var notes: String?
    @NSManaged public var range: String?
    @NSManaged public var athletes: NSSet?
    @NSManaged public var rounds: NSSet?

}

// MARK: Generated accessors for athletes
extension Sheet {

    @objc(addAthletesObject:)
    @NSManaged public func addToAthletes(_ value: Athlete)

    @objc(removeAthletesObject:)
    @NSManaged public func removeFromAthletes(_ value: Athlete)

    @objc(addAthletes:)
    @NSManaged public func addToAthletes(_ values: NSSet)

    @objc(removeAthletes:)
    @NSManaged public func removeFromAthletes(_ values: NSSet)

}

// MARK: Generated accessors for rounds
extension Sheet {

    @objc(addRoundsObject:)
    @NSManaged public func addToRounds(_ value: Round)

    @objc(removeRoundsObject:)
    @NSManaged public func removeFromRounds(_ value: Round)

    @objc(addRounds:)
    @NSManaged public func addToRounds(_ values: NSSet)

    @objc(removeRounds:)
    @NSManaged public func removeFromRounds(_ values: NSSet)

}
