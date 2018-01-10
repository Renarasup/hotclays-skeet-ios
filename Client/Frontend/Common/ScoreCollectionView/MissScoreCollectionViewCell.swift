//
//  MissScoreCollectionViewCell.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class MissScoreCollectionViewCell: ScoreCollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = AppColors.darkGray
    }

    override func draw(_ rect: CGRect) {
        // Draw a circle for a miss.
        let halfCellSideLength = 0.5 * self.bounds.width
        let indicatorScale = CommonConstants.shotIndicatorScale
        let circleBezierPath = UIBezierPath(arcCenter: CGPoint(x: halfCellSideLength, y: halfCellSideLength),
                                            radius: indicatorScale * halfCellSideLength,
                                            startAngle: 0.0,
                                            endAngle: 2.0 * CGFloat.pi,
                                            clockwise: false)
        circleBezierPath.lineWidth = CommonConstants.shotIndicatorStrokeLineWidth
        CommonConstants.shotIndicatorColor.setStroke()
        circleBezierPath.stroke()
    }

}
