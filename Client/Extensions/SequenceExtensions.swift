//
//  SequenceExtensions.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import Foundation

extension Sequence {

    /// Count the number of elements satisfying the given predicate.
    ///
    /// - Parameter predicate: Predicate that must be satisfied for an element to be included
    /// in the returned count.
    /// - Returns: Count of elements in the array that satisfy the given predicate.
    public func countWhere(_ predicate: (Element) -> Bool) -> Int {
        var count: Int = 0
        for element in self {
            if predicate(element) {
                count += 1
            }
        }
        return count
    }

}
