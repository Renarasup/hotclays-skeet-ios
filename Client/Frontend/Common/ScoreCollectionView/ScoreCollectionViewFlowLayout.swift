//
//  ScoreCollectionViewFlowLayout.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class ScoreCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func awakeFromNib() {
        self.itemSize = CGSize(square: 50.0)
        self.minimumInteritemSpacing = 20.0
        self.scrollDirection = .horizontal
    }
    
    /// Make horizontal scrolling of a `ScoreCollectionView` snap to stations.
    /// That is, snap cells to show one station at a time.
    ///
    /// - Parameter proposedContentOffset: Ending offset given scroll position and velocity.
    /// - Returns: New offset that should be used as the ending offset of this scroll.
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        // Get layout attributes for the proposed content offset.
        let horizontalOffset = proposedContentOffset.x + collectionView.contentInset.left
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
        let layoutAttributesArray = super.layoutAttributesForElements(in: targetRect)
        
        // Find the station closest to the proposed content offset.
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        var indexPath: IndexPath?
        if let indexPathOfClosestCell = layoutAttributesArray?.min(by: { (a, b) in fabsf(Float(a.frame.origin.x - offsetAdjustment)) < fabsf(Float(b.frame.origin.x - offsetAdjustment))})?.indexPath {
            // Compute options for two sections, rounding up or down.
            let sectionRoundingDown = indexPathOfClosestCell.section
            let sectionRoundingUp = min(Station.allValues.count - 1, indexPathOfClosestCell.section + 1)
            // Choose the actual `IndexPath` to which we'll scroll.
            if velocity.x < 0 {
                // Round down when scrolling to the left.
                indexPath = IndexPath(item: 0, section: sectionRoundingDown)
            } else if velocity.x > 0 {
                // Round up when scrolling to the right
                indexPath = IndexPath(item: 0, section: sectionRoundingUp)
            } else {
                // Round to the nearest station when dragging.
                let indexPathRoundingDown = IndexPath(item: 0, section: sectionRoundingDown)
                let indexPathRoundingUp = IndexPath(item: 0, section: sectionRoundingUp)
                var minDistance = Float.greatestFiniteMagnitude
                for indexPathChoice in [indexPathRoundingDown, indexPathRoundingUp] {
                    if let itemOffset = super.layoutAttributesForItem(at: indexPathChoice)?.frame.origin.x {
                        if fabsf(Float(itemOffset - horizontalOffset)) < minDistance {
                            indexPath = indexPathChoice
                            minDistance = fabsf(Float(itemOffset - horizontalOffset))
                        }
                    }
                }
            }
            
            // Set the new offset adjustment given our choice of `IndexPath`.
            if let indexPath = indexPath, let itemOffset = super.layoutAttributesForItem(at: indexPath)?.frame.origin.x {
                let station = Station(rawValue: Int16(indexPath.section + 1))!
                if station.numberOfShots == 4 {
                    // Align to left edge for 4-shot stations
                    offsetAdjustment = itemOffset - horizontalOffset
                } else {
                    // Align to left edge minus one cell of spacing for 4-shot stations
                    let view = collectionView.outermostSuperview!
                    let extraOffset = ScoreCollectionView.interItemSpacing(for: view) + ScoreCollectionView.cellSideLength(for: view)
                    offsetAdjustment = itemOffset - horizontalOffset - extraOffset
                }
            }
        }
        
        // Return the adjusted target content offset that will snap to a group of five cells.
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
}
