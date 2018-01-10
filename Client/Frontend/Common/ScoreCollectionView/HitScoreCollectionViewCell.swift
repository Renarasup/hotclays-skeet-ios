//
//  HitScoreCollectionViewCell.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class HitScoreCollectionViewCell: ScoreCollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = AppColors.orange
    }
    
    override func draw(_ rect: CGRect) {
        // Draw a slash for a hit.
        let halfCellSideLength = 0.5 * self.bounds.width
        let indicatorScale = CommonConstants.shotIndicatorScale
        let indicatorInset = (1.0 - indicatorScale) * halfCellSideLength
        let slashBezierPath = UIBezierPath()
        slashBezierPath.move(to: CGPoint(x: indicatorInset + 2.0 * indicatorScale * halfCellSideLength,
                                         y: indicatorInset))
        slashBezierPath.addLine(to: CGPoint(x: indicatorInset,
                                            y: indicatorInset + 2.0 * indicatorScale * halfCellSideLength))
        slashBezierPath.lineWidth = CommonConstants.shotIndicatorStrokeLineWidth
        slashBezierPath.lineCapStyle = .round
        CommonConstants.shotIndicatorColor.setStroke()
        slashBezierPath.stroke()
    }
    
}
