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
    
}
