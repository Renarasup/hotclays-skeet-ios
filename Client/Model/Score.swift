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
    
    // The option in a skeet score.
    private var option: Shot

    /// Serialized `Score`, where all shots come first and the option comes last.
    var description: String {
        return self.shots.map({ String(describing: $0) }).joined() + String(describing: self.option)
    }
    
    var numberOfAttempts: Int {
        return self.shots.countWhere({ $0 != .notTaken }) + (self.option == .notTaken ? 0 : 1)
    }
    
    var numberOfHits: Int {
        return self.shots.countWhere({ $0 == .hit }) + (self.option == .hit ? 1 : 0)
    }
    
    init() {
        self.shots = Array(repeating: .notTaken, count: Skeet.numberOfNonOptionShotsPerRound)
        self.option = .notTaken
    }
    
    init?(fromString scoreString: String) {
        if scoreString.count == Skeet.numberOfNonOptionShotsPerRound {
            let indexOfLastChar = scoreString.index(before: scoreString.endIndex)
            let shotString = scoreString[..<indexOfLastChar]
            self.shots = shotString.map({ Shot.fromCharacter($0) })
            self.option = Shot.fromCharacter(scoreString[indexOfLastChar])
        } else {
            return nil
        }
    }
    
    func setShot(atIndex index: Int, with shot: Shot) {
        self.shots[index] = shot
    }

    func getShot(atIndex index: Int) -> Shot {
        return self.shots[index]
    }
    
    func setOption(_ shot: Shot) {
        self.option = shot
    }
    
    func getOption() -> Shot {
        return self.option
    }

}
