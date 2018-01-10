//
//  Gauge.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//


/// Gauge of shotgun. Limited to gauges used in trap: 12, 20, 28, and .410 bore.
enum Gauge: Int16, CustomStringConvertible {
    case twelve = 12
    case twenty = 20
    case twentyEight = 28
    case fourTen = 410
    
    var description: String {
        switch self {
        case .twelve, .twenty, .twentyEight:
            return "\(self.rawValue) Gauge"
        case .fourTen:
            return ".\(self.rawValue) Bore"
        }
    }
    
    /// Default value for a Gauge.
    static let defaultValue = Gauge.twelve
    
    /// Array of all gauges in ascending order of difficulty.
    static let allValues: [Gauge] = [
        .twelve,
        .twenty,
        .twentyEight,
        .fourTen
    ]
}
