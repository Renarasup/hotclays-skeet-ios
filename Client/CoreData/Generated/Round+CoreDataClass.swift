//
//  Round+CoreDataClass.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Round)
public class Round: NSManagedObject {
    
    @discardableResult
    static func insert(with competingAthletes: [CompetingAthlete], on sheet: Sheet, roundNumber: Int) -> Round {
        assert(competingAthletes.count <= Skeet.maxNumberOfAthletesPerSquad, "Expected at most \(Skeet.maxNumberOfAthletesPerSquad) athletes.")
        let round = NSEntityDescription.insertNewObject(forEntityName: "Round", into: CoreDataManager.shared.managedObjectContext) as! Round

        round.roundNumber = Int16(roundNumber)
        round.scores = competingAthletes.map({ String(describing: $0) }).joined(separator: ";")
        round.sheet = sheet
        for competingAthlete in competingAthletes.flatMap({ $0 }) {
            let athlete = Athlete.getOrInsert(firstName: competingAthlete.firstName, lastName: competingAthlete.lastName)
            athlete.addToSheets(sheet)
        }

        CoreDataManager.shared.saveContext()

        return round
    }
    
    /// Get an array of `CompetingAthlete`s from a `Round`.
    func toCompetingAthletes() -> [CompetingAthlete] {
        var competingAthletes = [CompetingAthlete]()
        if let competingAthleteStrings = self.scores?.components(separatedBy: ";") {
            competingAthletes.append(contentsOf: competingAthleteStrings.flatMap({ CompetingAthlete(fromString: $0) }))
        }
        return competingAthletes
    }

    /// Get the number of hits in this round for an athlete with the given name.
    ///
    /// - Parameters:
    ///   - firstName: First name of athlete whose hits will be counted.
    ///   - lastName: Last name of athlete whose hits will be counted.
    /// - Returns: Number of hits for this athlete, or nil if no score was found for this athlete.
    func numberOfHitsForAthlete(withFirstName firstName: String, lastName: String) -> Int? {
        let competingAthletes = self.toCompetingAthletes()
        if let indexOfAthlete = competingAthletes.index(where: { $0.firstName == firstName && $0.lastName == lastName }) {
            return competingAthletes[indexOfAthlete].score.numberOfHits
        }
        return nil
    }
    
    /// Update a round with new `CompetingAthlete`s, and save the managed object context.
    ///
    /// - Parameter competingAthletes: The new `CompetingAthlete`s for the round.
    func update(withNew competingAthletes: [CompetingAthlete]) {
        self.managedObjectContext?.performAndWait {
            self.scores = competingAthletes.map({ String(describing: $0) }).joined(separator: ";")
            try? self.managedObjectContext?.save()
        }
    }

}
