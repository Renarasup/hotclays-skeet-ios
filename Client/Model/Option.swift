//
//  Option.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 3/26/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import Foundation


/// An option in skeet. Contains a `Shot` and a `Station`.
struct Option: CustomStringConvertible {
    
    let shot: Shot
    let station: Station?
    let house: House?
    
    var description: String {
        return String(describing: self.shot) + String(describing: self.station?.rawValue ?? 0) + String(describing: self.house?.rawValue ?? 0)
    }
    
    init?(fromString string: String) {
        let index0 = string.startIndex
        let index1 = string.index(string.startIndex, offsetBy: 1)
        let index2 = string.index(string.startIndex, offsetBy: 2)
        let index3 = string.index(string.startIndex, offsetBy: 3)
        if string.count == 3,
            let shotRawValue = Int16(string[index0..<index1]),
            let shot = Shot(rawValue: shotRawValue),
            let stationRawValue = Int16(string[index1..<index2]),
            let houseRawValue = Int16(string[index2..<index3]) {
            // Must be able to extract shot and (possibly nil) station and house values
            self.shot = shot
            self.station = Station(rawValue: stationRawValue)
            self.house = House(rawValue: houseRawValue)
        } else {
            return nil
        }
    }

    init(shot: Shot, station: Station, house: House) {
        if shot == .notTaken {
            fatalError("No-argument initializer must be used to set a notTaken option.")
        }
        self.shot = shot
        self.station = station
        self.house = house
    }
    
    init() {
        self.shot = .notTaken
        self.station = nil
        self.house = nil
    }

}
