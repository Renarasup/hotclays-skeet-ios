//
//  House.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 3/26/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import Foundation


/// House in skeet, either high or low.
enum House: Int16, CustomStringConvertible {
    
    case high = 1
    case low
    
    var description: String {
        switch self {
        case .high:
            return "High House"
        case .low:
            return "Low House"
        }
    }
    
    /// Array of all stations in ascending order.
    static let allValues: [House] = [
        .high,
        .low
    ]
    
    /// Get a `House` from an index of a non-option shot.
    init?(indexOfShot: Int) {
        let stationRawValue = Station.indexOfStation(for: indexOfShot) + 1
        if let station = Station(rawValue: Int16(stationRawValue)) {
            switch station {
            case .one, .two, .three, .four, .eight:
                // Stations at which you always shoot the high house first.
                self = (indexOfShot % 2 == 0) ? .high : .low
            case .five, .six, .seven:
                // Stations at which you shoot low house first on doubles.
                let indexOfShotWithinStation = Station.indexOfShotWithinStation(for: indexOfShot)
                if indexOfShotWithinStation < 2 {
                    // Singles shoot high house first
                    self = (indexOfShot % 2 == 0) ? .high : .low
                } else {
                    // Doubles shoot low house first
                    self = (indexOfShot % 2 == 0) ? .low : .high
                }
            }
        } else {
            return nil
        }
    }

}
