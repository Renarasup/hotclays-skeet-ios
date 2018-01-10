//
//  ScoreTableViewCell.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class ScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: ScoreCollectionView!
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    /// Get the height for a `ScoreTableViewCell` for a given view width.
    ///
    /// - Parameter viewWidth: Width of view containing the `ScoreTableViewCell`.
    /// - Returns: Height to use for the `ScoreTableViewCell`.
    static func heightForRow(for view: UIView) -> CGFloat {
        let cellSideLength = ScoreCollectionView.cellSideLength(for: view)
        return cellSideLength + 16.0 + 1.0 / UIScreen.main.scale
    }
    
    override func awakeFromNib() {
        self.informationView.layer.cornerRadius = CommonConstants.scoreCellCornerRadius
        self.informationView.clipsToBounds = true
    }

    func configure(with score: Score?, at indexOfAthlete: Int) {
        if let score = score {
            self.scoreLabel.text = "\(score.numberOfHits)"
        } else {
            self.scoreLabel.text = ""
        }
        self.collectionView.indexOfAthlete = indexOfAthlete
    }

    func update(with score: Score) {
        self.scoreLabel.text = "\(score.numberOfHits)"
    }

}
