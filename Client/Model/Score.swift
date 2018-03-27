//
//  Score.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//


/// The shots taken by an athlete during a single round.
class Score: CustomStringConvertible {
    
    /// Array of all shots except for the option.
    private var shots: [Shot]
    
    /// The option in a skeet score. Nil if not taken.
    private(set) var option: Option

    /// Serialized `Score`, where all shots come first and the option comes last.
    var description: String {
        return self.shots.map({ String(describing: $0) }).joined() + String(describing: self.option)
    }
    
    var numberOfAttempts: Int {
        return self.shots.countWhere({ $0 != .notTaken }) + (self.option.shot == .notTaken ? 0 : 1)
    }
    
    var numberOfHits: Int {
        return self.shots.countWhere({ $0 == .hit }) + (self.option.shot == .hit ? 1 : 0)
    }
    
    /// Check whether the next unattempted shot is the option
    var nextShotIsOption: Bool {
        if self.option.shot == .notTaken {
            if let indexOfFirstNotTaken = self.shots.index(of: .notTaken) {
                if let indexOfFirstMiss = self.shots.index(of: .miss) {
                    // Indices where we take the second shot in the double before taking the option
                    let delayedOptionIndices = [2, 6, 16, 20]
                    if delayedOptionIndices.contains(indexOfFirstMiss) {
                        // Make sure we've taken the next shot first
                        return indexOfFirstNotTaken == indexOfFirstMiss + 2
                    } else {
                        return true
                    }
                } else {
                    // Have not missed yet (and have not attempted all shots yet either).
                    return false
                }
            } else {
                // All non-option shots have been taken
                return true
            }
        } else {
            // Already took option
            return false
        }
    }

    var indexOfNextShot: Int {
        return self.shots.index(of: .notTaken) ?? Skeet.numberOfNonOptionShotsPerRound
    }
    
    init?(fromString string: String) {
        // Split into shots and option
        let indexOfFirstOptionChar = string.index(string.startIndex, offsetBy: Skeet.numberOfNonOptionShotsPerRound)
        let shotsString = string[..<indexOfFirstOptionChar]
        let optionString = string[indexOfFirstOptionChar...]
        
        // Parse the shots
        self.shots = []
        for i in 0..<Skeet.numberOfNonOptionShotsPerRound {
            let indexOfShotChar = string.index(string.startIndex, offsetBy: i)
            if let shotRawValue = Int16(shotsString[indexOfShotChar..<string.index(indexOfShotChar, offsetBy: 1)]),
                let shot = Shot(rawValue: shotRawValue) {
                self.shots.append(shot)
            } else {
                print("Failed to parse shots \(shotsString)")
                return nil
            }
        }
        
        // Parse the option
        if let option = Option(fromString: String(optionString)) {
            self.option = option
        } else {
            print("Failed to parse option \(optionString)")
            return nil
        }
    }
    
    init() {
        self.shots = Array(repeating: .notTaken, count: Skeet.numberOfNonOptionShotsPerRound)
        self.option = Option()
    }
    
    func setShot(atIndex index: Int, with shot: Shot) {
        self.shots[index] = shot
    }

    func getShot(atIndex index: Int) -> Shot {
        return index < Skeet.numberOfNonOptionShotsPerRound ? self.shots[index] : self.option.shot
    }

    func setOption(_ shot: Shot) {
        // Compute the station and house given this score
        if let indexOfFirstMiss = self.shots.index(of: .miss),
            let station = Station(indexOfShot: indexOfFirstMiss),
            let house = House(indexOfShot: indexOfFirstMiss) {
            // Option is the same station and house as the first miss
            self.option = Option(shot: shot, station: station, house: house)
        } else {
            // If no misses, option is taken on low eight
            self.option = Option(shot: shot, station: .eight, house: .low)
        }
    }
    
    func resetOption() {
        self.option = Option()
    }

}
