//
//  StringExtensions.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/16/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import Foundation

extension String {
    
    /// Generate a random alphanumeric `String` of the desired length.
    ///
    /// - Parameters:
    ///   - length: Number of characters in the random string to generate.
    ///   - excludingVowels: If `true`, exclude vowels. This is done to avoid generating profanity.
    /// - Returns: Random string of the given `length`.
    static func random(ofLength length: Int, excludingVowels: Bool = true) -> String {
        // Build alphabet from which to select.
        let alphabet: String
        if excludingVowels {
            alphabet = "bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ0123456789"
        } else {
            alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ0123456789"
        }
        
        // Add `length` random characters to the string.
        var randomString = ""
        for _ in 0..<length {
            let randomOffset = Int(arc4random_uniform(UInt32(alphabet.count)))
            randomString.append(alphabet[alphabet.index(alphabet.startIndex, offsetBy: randomOffset)])
        }
        
        return randomString
    }
    
}
