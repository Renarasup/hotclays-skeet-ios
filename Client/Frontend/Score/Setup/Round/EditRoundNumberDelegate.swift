//
//  EditRoundNumberDelegate.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/5/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import Foundation

protocol EditRoundNumberDelegate {
    
    /// Notify the delegate that a round was selected.
    func didSelect(_ roundNumber: Int)
    
}
