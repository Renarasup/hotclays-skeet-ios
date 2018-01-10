//
//  EditSquadDelegate.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import Foundation

protocol EditSquadDelegate {

    /// Notify the delegate of squad members that were selected.
    ///
    /// - Parameter athletes: `Athlete`s that were selected, causing this method to fire.
    func didSelect(_ athletes: [Athlete])

}
