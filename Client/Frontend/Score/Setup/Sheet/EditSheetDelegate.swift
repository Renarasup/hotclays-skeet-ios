//
//  EditSheetDelegate.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import Foundation


protocol EditSheetDelegate {
    
    /// Currently selected date, or nil if no date is selected yet.
    var date: Date? { get }
    
    /// Currently selected event, or nil if no event is selected yet.
    var event: String? { get }

    /// Currently selected range, or nil if no range is selected yet.
    var range: String? { get }

    /// Currently selected field, or nil if no field is selected yet.
    var field: String? { get }
    
    /// Current notes, or nil if no notes have been added yet.
    var notes: String? { get }

    /// Notify the delegate that the given date, event, range, and field were added.
    ///
    /// - Parameter date: Date that was added.
    /// - Parameter event: Event that was added.
    /// - Parameter range: Range that was added.
    /// - Parameter field: Field that was added.
    /// - Parameter notes: Notes that were added.
    func didAdd(date: Date, event: String, range: String, field: String?, notes: String?)
    
}
