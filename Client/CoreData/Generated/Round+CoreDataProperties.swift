//
//  Round+CoreDataProperties.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/5/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//
//

import Foundation
import CoreData


extension Round {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Round> {
        return NSFetchRequest<Round>(entityName: "Round")
    }

    @NSManaged public var firstScore: String?
    @NSManaged public var secondScore: String?
    @NSManaged public var thirdScore: String?
    @NSManaged public var fourthScore: String?
    @NSManaged public var fifthScore: String?
    @NSManaged public var roundNumber: Int16
    @NSManaged public var sheet: Sheet?

}
