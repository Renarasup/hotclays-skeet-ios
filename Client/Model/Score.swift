//
//  Score.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

/// The shots taken by an athlete during a single round.
class Score: CustomStringConvertible {
    
    private var shots: [Shot]
    
    var description: String {
        return self.shots.map({ String(describing: $0) }).joined()
    }
    
    var numberOfAttempts: Int {
        return self.shots.countWhere({ $0 != .notTaken })
    }
    
    var numberOfHits: Int {
        return self.shots.countWhere({ $0 == .hit })
    }
    
    init() {
        self.shots = Array(repeating: .notTaken, count: Trap.numberOfShotsPerRound)
    }
    
    init?(fromString scoreString: String) {
        if scoreString.count == Trap.numberOfShotsPerRound {
            self.shots = scoreString.map({ Shot.fromString("\($0)") })
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
    
    /// Count the number of hits at a given post index. For instance,
    /// if `indexOfStation` is 0, get the number of hits on the first 5 shots.
    ///
    /// - Parameter indexOfStation: Index of the post on which to count the shooters hits,
    /// indexed from 0 starting at the user's starting post.
    /// - Returns: Number of hits on that post. Guaranteed to be between 0 and 5.
    func numberOfHitsAt(_ indexOfStation: Int) -> Int {
        let lowIndex = indexOfStation * Trap.numberOfShotsPerStation
        let highIndex = lowIndex + Trap.numberOfShotsPerStation
        return self.shots[lowIndex..<highIndex].countWhere({ $0 == .hit })
    }

}
