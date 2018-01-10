//
//  Athlete+CoreDataClass.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Athlete)
public class Athlete: NSManagedObject {
    
    /// Athlete's first and last name, separated by a space.
    override public var description: String {
        return "\(self.firstName ?? "") \(self.lastName ?? "")"
    }

    /// Insert an `Athlete` into Core Data. Set default gauge and yardage to the defaults
    /// (12 gauge and 16 yards).
    ///
    /// - Parameters:
    ///   - firstName: First name of athlete.
    ///   - lastName: Last name of athlete.
    /// - Returns: The `Athlete` that was inserted.
    @discardableResult
    static func insert(firstName: String, lastName: String, isOnTeam: Bool) -> Athlete {
        let athlete = NSEntityDescription.insertNewObject(forEntityName: "Athlete", into: CoreDataManager.shared.managedObjectContext) as! Athlete

        athlete.firstName = firstName
        athlete.lastName = lastName
        athlete.isOnTeam = isOnTeam
        athlete.defaultGauge = Gauge.defaultValue.rawValue
        athlete.defaultYardage = Yardage.defaultValue.rawValue

        CoreDataManager.shared.saveContext()

        return athlete
    }

    /// Look up an `Athlete` in Core Data by name. If no such athlete exists, insert one.
    /// By default, the inserted athlete is not on the current user's team.
    static func getOrInsert(firstName: String, lastName: String) -> Athlete {
        var athlete: Athlete?
        let context = CoreDataManager.shared.managedObjectContext
        let request: NSFetchRequest<Athlete> = Athlete.fetchRequest()
        request.predicate = NSPredicate(format: "firstName == %@ && lastName == %@", firstName, lastName)
        context.performAndWait {
            athlete = (try? context.fetch(request))?.first
        }
        return athlete ?? Athlete.insert(firstName: firstName, lastName: lastName, isOnTeam: false)
    }

    /// Transient property for grouping `Athlete`s into sections based on first
    /// letter of last name.
    @objc public var firstLetterOfLastName: String? {
        self.willAccessValue(forKey: "firstLetterOfLastName")
        var firstLetter = "#"
        if let lastName = self.lastName, lastName.count > 0 {
            let rangeForFirstLetter = lastName.startIndex ..< lastName.index(lastName.startIndex, offsetBy: 1)
            firstLetter = String(lastName[rangeForFirstLetter]).uppercased()
        }
        self.didAccessValue(forKey: "firstLetterOfLastName")
        
        // Return "#" if number.
        switch firstLetter {
        case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
            return "#"
        default:
            return firstLetter
        }
    }
    
    /// Delete all `Athlete`s from Core Data.
    ///
    /// - Parameter keepTeamMembers: If `true`, only delete non-team members.
    static func deleteAll(keepTeamMembers: Bool = false) {
        let context = CoreDataManager.shared.managedObjectContext
        let request: NSFetchRequest<Athlete> = Athlete.fetchRequest()
        if keepTeamMembers {
            request.predicate = NSPredicate(format: "isOnTeam == %@", NSNumber(booleanLiteral: false))
        }
        request.returnsObjectsAsFaults = false
        context.perform({
            if let athletes = try? context.fetch(request) {
                for athlete in athletes {
                    context.delete(athlete)
                }
                try? context.save()
            }
        })
    }
    
}
