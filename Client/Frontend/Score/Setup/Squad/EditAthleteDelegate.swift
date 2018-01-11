//
//  EditAthleteDelegate.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/5/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//


protocol EditAthleteDelegate {

    
    /// Notify the delegate that a given athlete was edited.
    ///
    /// - Parameters:
    ///   - indexOfAthlete: Index of athlete in squad.
    ///   - gauge: Gauge that was selected.
    func didEditAthlete(at indexOfAthlete: Int, gauge: Gauge)

}

