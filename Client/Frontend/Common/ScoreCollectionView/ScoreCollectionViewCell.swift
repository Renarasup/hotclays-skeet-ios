//
//  ScoreCollectionViewCell.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

/// Base class for a cell stored in a `ScoreCollectionView`.
/// Subclasses set their background color and draw a shot indicator (i.e., slash or circle).
class ScoreCollectionViewCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = CommonConstants.scoreCellCornerRadius
        self.layer.borderColor = AppColors.black.cgColor
    }

    /// Configure to be selected or not selected
    ///
    /// - Parameters:
    ///   - isHighlighted: If true, set selected. Otherwise, set unselected.
    func setSelected(_ isSelected: Bool) {
        if isSelected {
            self.layer.borderWidth = CommonConstants.scoreCellSelectedBorderWidth
        } else {
            self.layer.borderWidth = CGFloat(0)
        }
    }

}
