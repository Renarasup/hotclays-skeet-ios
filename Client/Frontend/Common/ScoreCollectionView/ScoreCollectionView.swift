//
//  ScoreCollectionView.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class ScoreCollectionView: UICollectionView {

    static let maximumStackViewWidth = CGFloat(745.0)
    
    var indexOfAthlete: Int!
    
    static func inset(for view: UIView, forSectionAt section: Int) -> UIEdgeInsets {
        var extraInset = CGFloat(0)
        let station = Station(rawValue: Int16(section + 1))!
        if station.numberOfShots == 2 {
            // Extra spacing to make the section same width as 4-shot station
            extraInset = interItemSpacing(for: view) + cellSideLength(for: view)
        }
        // Spacing between sections, but no extra spacing on the outer edges.
        let spacingBetweenSections = interSectionSpacing(for: view)
        let leftInset = section == 0 ? CGFloat(0.0) : spacingBetweenSections
        let rightInset = section == Station.allValues.count - 1 ? CGFloat(0.0) : spacingBetweenSections
        return UIEdgeInsetsMake(0.0, leftInset + extraInset, 0.0, rightInset + extraInset)
    }
    
    static func interItemSpacing(for view: UIView) -> CGFloat {
        // TODO: Adaptive inter-item spacing.
        return 10.0
    }
    
    static func interSectionSpacing(for view: UIView) -> CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? CGFloat(40.0) : CGFloat(20.0)
    }
    
    /// Get the side length for a `ScoreCollectionViewCell` given the available
    /// width of the containing view. Limit to a maximum width.
    ///
    /// - Parameter viewWidth: Width of view containing the `ScoreCollectionView`
    /// in which the cell resides.
    /// - Returns: Width to use for the `ScoreCollectionViewCell`.
    static func cellSideLength(for view: UIView) -> CGFloat {
        let numberOfCells = CGFloat(6)
        let paddingOnTheEnds = view.layoutMargins.left + view.layoutMargins.right
        let paddingBetweenCells = interItemSpacing(for: view)
        
        // Compute total padding and total available width. Limit width to maxScoreStackViewWidth.
        var totalPadding = paddingBetweenCells * (numberOfCells - 1.0) + paddingOnTheEnds
        var availableWidth = view.bounds.width
        if availableWidth - paddingOnTheEnds > maximumStackViewWidth {
            totalPadding -= paddingOnTheEnds
            availableWidth = maximumStackViewWidth
        }
        
        // Round the side length to the nearest float that can be represented on screen.
        let sideLength = (availableWidth - totalPadding) / numberOfCells
        let sideLengthScaled = sideLength * UIScreen.main.scale
        let sideLengthInPixels = sideLengthScaled.rounded(.down) / UIScreen.main.scale
        return sideLengthInPixels
    }
    
    override func awakeFromNib() {
        self.decelerationRate = UIScrollViewDecelerationRateFast
    }

}
