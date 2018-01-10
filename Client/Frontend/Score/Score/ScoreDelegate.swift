//
//  ScoreDelegate.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/5/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import Foundation


protocol ScoreDelegate {
    
    /// Notify the delegate that a round was completed and a given `Sheet` was saved.
    ///
    /// - Parameter sheet: Final `Sheet` that was saved.
    func didSave(_ sheet: Sheet)
    
}
