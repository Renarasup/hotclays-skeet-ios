//
//  AddAthleteDelegate.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/9/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//


protocol AddAthleteDelegate {
    
    /// Notify the delegate that an `Athlete` was added.
    ///
    /// - Parameter athlete: `Athlete` that was added.
    func didAdd(_ athlete: Athlete)

}
