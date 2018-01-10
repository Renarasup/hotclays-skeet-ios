//
//  EditTeamInfoDelegate.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/7/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import Foundation

protocol EditTeamInfoDelegate {

    /// Notify the delegate that a team name and location were selected.
    ///
    /// - Parameters:
    ///   - teamName: Name of team.
    ///   - teamLocation: Location of team.
    func didSelect(teamName: String, teamLocation: String)
    
}
