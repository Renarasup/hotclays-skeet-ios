//
//  Shot.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import Foundation

/// Result of a shot.
enum Shot: Int16, CustomStringConvertible {
    
    // Standard hit, miss, or not taken
    case miss
    case hit
    case notTaken
    
    // Miss with direction information
    case missHardLeft
    case missLeft
    case missCenter
    case missRight
    case missHardRight
    
    var description: String {
        return "\(self.rawValue)"
    }

    /// Convert a single-character `String` to a `Shot`.
    ///
    /// - Parameter string: The single-character `String` to convert to a `Shot`.
    /// - Returns: Shot represented by the given character.
    static func fromString(_ string: String) -> Shot {
        if let i = Int16(string), let shot = Shot(rawValue: i) {
            return shot
        }
        return .notTaken
    }

    /// Check whether a shot encodes direction information
    /// (e.g., `.missHardLeft` does, but `.miss` and `.hit` do not).
    ///
    /// - Returns: True if this shot encodes direction information.
    var encodesDirection: Bool {
        switch self {
        case .missHardLeft, .missLeft, .missCenter, .missRight, .missHardRight:
            return true
        case .miss, .hit, .notTaken:
            return false
        }
    }
    
}
