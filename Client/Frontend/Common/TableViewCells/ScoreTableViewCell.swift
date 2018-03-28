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
    @IBOutlet weak var optionHitIndicatorView: HitScoreCollectionViewCell!
    @IBOutlet weak var optionMissIndicatorView: MissScoreCollectionViewCell!
    @IBOutlet weak var optionNotTakenIndicatorView: NotTakenScoreCollectionViewCell!
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var delegate: ScoreTableViewCellDelegate!
    
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
        
        // Listen for taps on the option view.
        let tapOption = UITapGestureRecognizer(target: self, action: #selector(pressedOptionView(_:)))
        self.optionView.addGestureRecognizer(tapOption)
    }

    @objc func pressedOptionView(_ gestureRecognizer: UIGestureRecognizer) {
        self.delegate.didTapOptionCell(forIndexOfAthlete: self.collectionView.indexOfAthlete)
    }

    func configure(with score: Score?, at indexOfAthlete: Int, isTakingOption: Bool) {
        if let score = score {
            self.updateOption(with: score.option, isTakingOption: isTakingOption)
            self.scoreLabel.text = "\(score.numberOfHits)"
        } else {
            self.updateOption(with: Option(), isTakingOption: false)
            self.scoreLabel.text = ""
        }

        self.collectionView.indexOfAthlete = indexOfAthlete
    }
    
    private func updateOption(with option: Option, isTakingOption: Bool) {
        // Select which indicator to display
        let indicatorViewToShow: ScoreCollectionViewCell!
        switch option.shot {
        case .hit:
            indicatorViewToShow = self.optionHitIndicatorView
        case .miss:
            indicatorViewToShow = self.optionMissIndicatorView
        case .notTaken:
            indicatorViewToShow = self.optionNotTakenIndicatorView
        }
        // Show the correct indicator view and no others.
        let indicatorViews: [ScoreCollectionViewCell] = [self.optionHitIndicatorView, self.optionMissIndicatorView, self.optionNotTakenIndicatorView]
        for indicatorView in indicatorViews {
            indicatorView.isHidden = (indicatorView != indicatorViewToShow)
        }
        // Draw a border if selected. Animate border changes to match `UICollectionViewCell` border changes.
        indicatorViewToShow.layer.borderWidth = CommonConstants.scoreCellSelectedBorderWidth
        
        let originalBorderColor = isTakingOption ? UIColor.clear.cgColor : AppColors.black.cgColor
        indicatorViewToShow.layer.borderColor = originalBorderColor
        let finalBorderColor = isTakingOption ? AppColors.black.cgColor : UIColor.clear.cgColor
        let borderColorAnimation: CABasicAnimation = CABasicAnimation(keyPath: "borderColor")
        borderColorAnimation.fromValue = originalBorderColor
        borderColorAnimation.toValue = finalBorderColor
        borderColorAnimation.duration = 0.2
        indicatorViewToShow.layer.add(borderColorAnimation, forKey: "color")
        indicatorViewToShow.layer.borderColor = finalBorderColor
    }

    func update(with score: Score) {
        self.scoreLabel.text = "\(score.numberOfHits)"
    }

}

protocol ScoreTableViewCellDelegate {
    
    func didTapOptionCell(forIndexOfAthlete indexOfAthlete: Int)
    
}
