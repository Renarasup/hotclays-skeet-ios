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

    /// The number of shots taken at a given station, not including the option.
    static func numberOfShots(at station: Station) -> Int {
        switch station {
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
    
}
