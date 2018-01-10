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
    let STRING_INDEX_OF_FIRST_STATION = 2
    let STRING_INDEX_OF_GAUGE = 3
    let STRING_INDEX_OF_YARDAGE = 4
    let STRING_INDEX_OF_SCORE = 5
    /// Components: First name, last name, first station, gauge, yardage, score.
    let NUMBER_OF_STRING_COMPONENTS = 6
    
    var firstName: String
    var lastName: String
    var gauge: Gauge
    var firstStation: Station
    var score: Score
    var yardage: Yardage
    
    var fullName: String {
        return "\(self.firstName) \(self.lastName)"
    }
    
    /// Comma-separated string of four components:
    /// Name, first station, score string, and total score.
    var description: String {
        let components = [self.firstName,
                          self.lastName,
                          String(describing: self.firstStation.rawValue),
                          String(describing: self.gauge.rawValue),
                          String(describing: self.yardage.rawValue),
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
        self.firstStation = Station.defaultValue
        self.gauge = Gauge(rawValue: athlete.defaultGauge) ?? Gauge.defaultValue
        self.score = Score()
        self.yardage = Yardage(rawValue: athlete.defaultYardage) ?? Yardage.defaultValue
    }

    /// Initialize from a string stored in Core Data.
    init?(fromString string: String?) {
        guard let string = string else { return nil }
        let components = string.components(separatedBy: ",")
        if components.count == NUMBER_OF_STRING_COMPONENTS,
            let firstStation = Station(rawValue: Int16(components[STRING_INDEX_OF_FIRST_STATION]) ?? 0),
            let gauge = Gauge(rawValue: Int16(components[STRING_INDEX_OF_GAUGE]) ?? 0),
            let yardage = Yardage(rawValue: Int16(components[STRING_INDEX_OF_YARDAGE]) ?? 0),
            let score = Score(fromString: components[STRING_INDEX_OF_SCORE]) {
            // Valid serialized `CompetingAthlete`.
            self.firstName = components[STRING_INDEX_OF_FIRST_NAME]
            self.lastName = components[STRING_INDEX_OF_LAST_NAME]
            self.firstStation = firstStation
            self.gauge = gauge
            self.yardage = yardage
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
