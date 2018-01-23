//
//  EditRoundDelegate.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/8/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import Foundation

protocol EditRoundDelegate {
    
    
    /// Notify the delegate that the round was updated.
    ///
    /// - Parameter competingAthletes: Array of new `CompetingAthlete`s in the round.
    /// These will replace the old names, scores, gauges, etc. in the round.
    func didEditRound(withNew competingAthletes: [CompetingAthlete])

}
