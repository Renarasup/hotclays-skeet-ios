//
//  ArrayExtensions.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import Foundation


extension Array {

    /// Get the index of the last element satisfying the given predicate.
    ///
    /// - Parameter predicate: Predicate that must be satisfied by element at returned index.
    /// - Returns: Index of last element satisfying the predicate. Nil if no such element exists.
    public func indexOfLast(where predicate: (Element) -> Bool) -> Int? {
        var indexOfLast = self.count - 1
        while indexOfLast >= 0 && !predicate(self[indexOfLast]) {
            indexOfLast -= 1
        }
        return indexOfLast >= 0 ? indexOfLast : nil
    }

}

extension Array where Element:Equatable {

    /// Get a copy of this array with no duplicates.
    /// Preserve order of original array.
    ///
    /// - Returns: Same array with all duplicates removed.
    func removingDuplicates() -> [Element] {
        var result = [Element]()
        for value in self {
            if !result.contains(value) {
                result.append(value)
            }
        }
        return result
    }

}

