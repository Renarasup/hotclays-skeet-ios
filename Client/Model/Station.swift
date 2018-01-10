//
//  Station.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

/// Trap station.
enum Station: Int16, CustomStringConvertible {
    
    case one = 1
    case two
    case three
    case four
    case five

    var description: String {
        return "Station \(self.rawValue)"
    }
    
    /// Default value for a station.
    static let defaultValue = Station.one
    
    /// Array of all stations in ascending order.
    static let allValues: [Station] = [
        .one,
        .two,
        .three,
        .four,
        .five
    ]
    
    /// Get the next post after this one.
    ///
    /// - Parameter numberOfPostsToAdvance: The number of posts by which to advance. Defaults to 1.
    /// - Returns: Next post advancing by the specified number.
    func next(advancingBy numberOfPostsToAdvance: Int = 1) -> Station {
        let indexOfNextPost = Int(self.rawValue) + numberOfPostsToAdvance - 1
        let nextRawValue = Int16(indexOfNextPost % Station.allValues.count) + 1
        return Station(rawValue: nextRawValue)!
    }
    
}
