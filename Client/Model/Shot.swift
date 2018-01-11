//
//  Shot.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import Foundation

/// Result of a shot in skeet.
enum Shot: Int16, CustomStringConvertible {
    
    // Standard hit, miss, or not taken.
    case miss
    case hit
    case notTaken
    
    var description: String {
        return "\(self.rawValue)"
    }

    /// Convert a single `Character` to a `Shot`.
    ///
    /// - Parameter character: The single `Character` to convert to a `Shot`.
    /// - Returns: Shot represented by the given character.
    static func fromCharacter(_ character: Character) -> Shot {
        if let i = Int16("\(character)"), let shot = Shot(rawValue: i) {
            return shot
        }
        return .notTaken
    }
    
}
