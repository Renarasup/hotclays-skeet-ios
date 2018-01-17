//
//  ChooseSheetDelegate.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/16/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import Foundation

protocol ChooseSheetDelegate {
    
    /// Notify the delegate that an existing `Sheet` was chosen.
    ///
    /// - Parameter sheet: The `Sheet` that was chosen.
    func didChoose(_ sheet: Sheet)
    
}

