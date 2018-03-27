//
//  Station.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

/// Skeet station.
enum Station: Int16, CustomStringConvertible {

    case one = 1
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight

    var description: String {
        return "Station \(self.rawValue)"
    }
    
    /// Number of shots taken on this station, not including option.
    var numberOfShots: Int {
        switch self {
        case .one, .two, .six, .seven:
            return 4
        case .three, .four, .five, .eight:
            return 2
        }
    }

    /// Default value for a station.
    static let defaultValue = Station.one

    /// Array of all stations in ascending order.
    static let allValues: [Station] = [
        .one,
        .two,
        .three,
        .four,
        .five,
        .six,
        .seven,
        .eight
    ]
    
    /// Get the index of the station on which a particular shot is taken.
    ///
    /// - Parameter indexOfShot: Index of non-option shot (0 - 23).
    static func indexOfStation(for indexOfShot: Int) -> Int {
        guard indexOfShot >= 0 && indexOfShot < Skeet.numberOfNonOptionShotsPerRound else {
            fatalError("Invalid indexOfShot \(indexOfShot) passed to indexOfStation.")
        }
        
        if indexOfShot < 4 {
            return 0  // Station 1
        } else if indexOfShot < 8 {
            return 1  // Station 2
        } else if indexOfShot < 10 {
            return 2  // Station 3
        } else if indexOfShot < 12 {
            return 3  // Station 4
        } else if indexOfShot < 14 {
            return 4  // Station 5
        } else if indexOfShot < 18 {
            return 5  // Station 6
        } else if indexOfShot < 22 {
            return 6
        } else {
            return 7
        }
    }
    
    /// Get the index of the shot within the station on which a particular shot is taken
    ///
    /// - Parameter indexOfShot: Index of non-option shot (0 - 23).
    static func indexOfShotWithinStation(for indexOfShot: Int) -> Int {
        guard indexOfShot >= 0 && indexOfShot < Skeet.numberOfNonOptionShotsPerRound else {
            fatalError("Invalid indexOfShot \(indexOfShot) passed to indexOfShotWithinStation.")
        }
        
        if indexOfShot < 4 {
            return indexOfShot  // Station 1
        } else if indexOfShot < 8 {
            return indexOfShot - 4  // Station 2
        } else if indexOfShot < 10 {
            return indexOfShot - 8  // Station 3
        } else if indexOfShot < 12 {
            return indexOfShot - 10  // Station 4
        } else if indexOfShot < 14 {
            return indexOfShot - 12  // Station 5
        } else if indexOfShot < 18 {
            return indexOfShot - 14  // Station 6
        } else if indexOfShot < 22 {
            return indexOfShot - 18
        } else {
            return indexOfShot - 22
        }
    }

    /// Get the next station after this one.
    ///
    /// - Parameter stepSize: The number of stations by which to advance. Defaults to 1.
    /// - Returns: Next post advancing by the specified number.
    func next(advancingBy stepSize: Int = 1) -> Station {
        let indexOfNextPost = Int(self.rawValue) + stepSize - 1
        let nextRawValue = Int16(indexOfNextPost % Station.allValues.count) + 1
        return Station(rawValue: nextRawValue)!
    }

}
