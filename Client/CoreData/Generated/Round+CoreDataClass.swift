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
    static func insert(with competingAthletes: [CompetingAthlete?], on sheet: Sheet, roundNumber: Int) -> Round {
        assert(competingAthletes.count == Station.allValues.count, "Expected five CompetingAthletes")
        let round = NSEntityDescription.insertNewObject(forEntityName: "Round", into: CoreDataManager.shared.managedObjectContext) as! Round

        round.roundNumber = Int16(roundNumber)
        round.firstScore = competingAthletes[0]?.description
        round.secondScore = competingAthletes[1]?.description
        round.thirdScore = competingAthletes[2]?.description
        round.fourthScore = competingAthletes[3]?.description
        round.fifthScore = competingAthletes[4]?.description
        round.sheet = sheet
        for competingAthlete in competingAthletes.flatMap({ $0 }) {
            let athlete = Athlete.getOrInsert(firstName: competingAthlete.firstName, lastName: competingAthlete.lastName)
            athlete.addToSheets(sheet)
        }

        CoreDataManager.shared.saveContext()

        return round
    }
    
    /// Get an array of `CompetingAthlete`s from a `Round`.
    func toCompetingAthletes() -> [CompetingAthlete?] {
        var competingAthletes = [CompetingAthlete?]()
        competingAthletes.append(CompetingAthlete(fromString: self.firstScore))
        competingAthletes.append(CompetingAthlete(fromString: self.secondScore))
        competingAthletes.append(CompetingAthlete(fromString: self.thirdScore))
        competingAthletes.append(CompetingAthlete(fromString: self.fourthScore))
        competingAthletes.append(CompetingAthlete(fromString: self.fifthScore))
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
        if let indexOfAthlete = competingAthletes.index(where: { $0?.firstName == firstName && $0?.lastName == lastName }) {
            return competingAthletes[indexOfAthlete]?.score.numberOfHits
        }
        return nil
    }
    
    
    /// Update a round with new `CompetingAthlete`s, and save the managed object context.
    ///
    /// - Parameter competingAthletes: The new `CompetingAthlete`s for the round.
    func update(withNew competingAthletes: [CompetingAthlete?]) {
        self.managedObjectContext?.performAndWait {
            self.firstScore = competingAthletes[0]?.description
            self.secondScore = competingAthletes[1]?.description
            self.thirdScore = competingAthletes[2]?.description
            self.fourthScore = competingAthletes[3]?.description
            self.fifthScore = competingAthletes[4]?.description
            try? self.managedObjectContext?.save()
        }
    }

}
