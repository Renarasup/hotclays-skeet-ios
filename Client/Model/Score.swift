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
        return self.shots[index]
    }

    func setOption(_ shot: Shot, at station: Station, house: House) {
        self.option = Option(shot: shot, station: station, house: house)
    }
    
    func resetOption() {
        self.option = Option()
    }

}
