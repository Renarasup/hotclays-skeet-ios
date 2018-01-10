//
//  IntExtensions.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/5/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import Foundation

extension Int {

    /// Compute non-negative modulus of two integers.
    ///
    /// - Parameters:
    ///   - a: Value in expression `a mod b`.
    ///   - b: Base in expression `a mod b`.
    /// - Returns: Non-negative equivalence class of `a mod b`.
    static func mod(_ a: Int, _ b: Int) -> Int {
        guard b > 0 else {
            fatalError("mod requires positive modulus")
        }
        let r = a % b
        return r >= 0 ? r : r + b
    }

}
