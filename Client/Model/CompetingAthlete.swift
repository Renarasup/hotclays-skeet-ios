//
//  CompetingAthlete.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import Foundation

/// An `Athlete` when competing.
class CompetingAthlete: CustomStringConvertible, Equatable {
    
    let STRING_INDEX_OF_FIRST_NAME = 0
    let STRING_INDEX_OF_LAST_NAME = 1
    let STRING_INDEX_OF_GAUGE = 2
    let STRING_INDEX_OF_SCORE = 3
    /// Components: First name, last name, gauge, and score.
    let NUMBER_OF_STRING_COMPONENTS = 4
    
    var firstName: String
    var lastName: String
    var gauge: Gauge
    var score: Score
    
    var hasTakenOption: Bool {
        return score.option.shot != .notTaken
    }
    
    var hasTakenAllNonOptionShots: Bool {
        let numberOfAttempts = self.score.numberOfAttempts
        let hasTakenAllButOption = numberOfAttempts == Skeet.numberOfNonOptionShotsPerRound && !self.hasTakenOption
        let hasTakenAll = numberOfAttempts > Skeet.numberOfNonOptionShotsPerRound
        return hasTakenAll || hasTakenAllButOption
    }
    
    var nextShotIsOption: Bool {
        return self.score.nextShotIsOption
    }
    
    var indexOfNextShot: Int {
        return self.score.indexOfNextShot
    }
    
    var fullName: String {
        return "\(self.firstName) \(self.lastName)"
    }
    
    /// Comma-separated string of five components:
    /// First name, last name, gauge, and score string.
    var description: String {
        let components = [self.firstName,
                          self.lastName,
                          String(describing: self.gauge.rawValue),
                          String(describing: self.score)]
        return components.joined(separator: ",")
    }

    /// Compare two `CompetingAthlete`s for equality. They are equal if and only if
    /// they contain the same `firstName` and `lastName`.
    static func ==(lhs: CompetingAthlete, rhs: CompetingAthlete) -> Bool {
        return lhs.firstName == rhs.firstName && lhs.lastName == rhs.lastName
    }
    
    init(athlete: Athlete) {
        self.firstName = athlete.firstName ?? ""
        self.lastName = athlete.lastName ?? ""
        self.gauge = Gauge(rawValue: athlete.defaultGauge) ?? Gauge.defaultValue
        self.score = Score()
    }

    /// Initialize from a string stored in Core Data.
    init?(fromString string: String?) {
        guard let string = string else { return nil }
        let components = string.components(separatedBy: ",")
        if components.count == NUMBER_OF_STRING_COMPONENTS,
            let gauge = Gauge(rawValue: Int16(components[STRING_INDEX_OF_GAUGE]) ?? 0),
            let score = Score(fromString: components[STRING_INDEX_OF_SCORE]) {
            // Valid serialized `CompetingAthlete`.
            self.firstName = components[STRING_INDEX_OF_FIRST_NAME]
            self.lastName = components[STRING_INDEX_OF_LAST_NAME]
            self.gauge = gauge
            self.score = score
            return
        }
        // Return nil if any part failed.
        return nil
    }

    func resetScore() {
        self.score = Score()
    }
    
}
