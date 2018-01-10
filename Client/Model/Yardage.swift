//
//  Yardage.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//


/// Handicap yardage. Limited to yardages used in trap:
enum Yardage: Int16, CustomStringConvertible {
    case sixteen = 16
    case seventeen
    case eighteen
    case nineteen
    case twenty
    case twentyOne
    case twentyTwo
    case twentyThree
    case twentyFour
    case twentyFive
    case twentySix
    case twentySeven
    
    var description: String {
        return "\(self.rawValue) Yards"
    }
    
    /// Default value for a Yardage.
    static let defaultValue = Yardage.sixteen
    
    /// Array of all yardages in ascending order of distance from the house.
    static let allValues: [Yardage] = [
        .sixteen,
        .seventeen,
        .eighteen,
        .nineteen,
        .twenty,
        .twentyOne,
        .twentyTwo,
        .twentyThree,
        .twentyFour,
        .twentyFive,
        .twentySix,
        .twentySeven
    ]
}
