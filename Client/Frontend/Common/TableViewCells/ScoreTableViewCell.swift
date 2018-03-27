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
    @IBOutlet weak var optionView: UIView!
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
        
        self.optionView.layer.cornerRadius = CommonConstants.scoreCellCornerRadius
        self.optionView.clipsToBounds = true
    }

    func configure(with score: Score?, at indexOfAthlete: Int) {
        if let score = score {
            self.setOption(score.option, selected: false)
            self.scoreLabel.text = "\(score.numberOfHits)"
        } else {
            self.setOption(Option(), selected: false)
            self.scoreLabel.text = ""
        }

        self.collectionView.indexOfAthlete = indexOfAthlete
    }

    func update(with score: Score) {
        self.scoreLabel.text = "\(score.numberOfHits)"
    }
    
    func setOption(_ option: Option, selected: Bool) {
        // Set background for given option
        switch option.shot {
        case .hit:
            self.optionView.backgroundColor = AppColors.orange
        case .miss:
            self.optionView.backgroundColor = AppColors.darkGray
        case .notTaken:
            self.optionView.backgroundColor = AppColors.lightGray
        }
        
        // TODO: Draw hit/miss indicator
        
        // TODO: Indicate where the option was taken
        
        // Set border for selected state
        if selected {
            self.optionView.layer.borderColor = AppColors.black.cgColor
            self.optionView.layer.borderWidth = CommonConstants.scoreCellSelectedBorderWidth
        } else {
            self.optionView.layer.borderWidth = 0.0
        }
    }

}
