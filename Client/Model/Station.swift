//
//  Station.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

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
    
    /// Check whether a given shot index is the last shot on a station.
    /// Used to determine when we should switch shooters (in particular,
    /// note that we switch after shot index 22, even though not technically end of a station).
    static func isLastShotOnStation(_ indexOfShot: Int) -> Bool {
        switch indexOfShot {
        case 3, 7, 9, 11, 13, 17, 21, 22, 23:
            return true
        default:
            return false
        }
    }
    
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

    /// Get an indexOfShot from an `IndexPath`, assuming the index path
    /// is stored as in a `ScoreCollectionView`, where we store each station
    /// in its own section.
    ///
    /// - Parameter indexPath: `IndexPath` of the shot.
    /// - Returns: Index of shot, a number 0 - 24.
    static func indexOfShot(from indexPath: IndexPath) -> Int {
        var shotsTakenOnPreviousStations = 0
        var stationRawValue = 1
        while stationRawValue <= indexPath.section {
            let previousStation = Station(rawValue: Int16(stationRawValue))!
            shotsTakenOnPreviousStations += previousStation.numberOfShots
            stationRawValue += 1
        }
        return shotsTakenOnPreviousStations + indexPath.item
    }
    
    init?(indexOfShot: Int) {
        let stationRawValue = Station.indexOfStation(for: indexOfShot) + 1
        if let stationValue = Station(rawValue: Int16(stationRawValue)) {
            self = stationValue
        } else {
            return nil
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
