//
//  ScoreViewController+UICollectionViewExtensions.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/5/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit


extension ScoreViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // TODO: Adapt number of sections for skeet.
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 4 ? 4 : Skeet.numberOfShotsPerStation
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Get the shot to display (i.e., hit, miss, or none if not yet attempted).
        let indexOfAthlete = (collectionView as! ScoreCollectionView).indexOfAthlete!
        let indexOfShot = indexPath.section * Skeet.numberOfShotsPerStation + indexPath.item
        let shot = self.competingAthletes[indexOfAthlete].score.getShot(atIndex: indexOfShot)
        
        let cell: ScoreCollectionViewCell
        if shot == .notTaken {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommonConstants.notTakenScoreCollectionViewCellID, for: indexPath) as! NotTakenScoreCollectionViewCell
        } else if shot == .hit {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommonConstants.hitScoreCollectionViewCellID, for: indexPath) as! HitScoreCollectionViewCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommonConstants.missScoreCollectionViewCellID, for: indexPath) as! MissScoreCollectionViewCell
        }
        
        // Draw cursor on the cell if it represents the current athlete and shot.
        let isCurrentShooter = indexOfAthlete == self.cursor.indexOfAthlete
        let isCurrentShot = indexOfShot == self.cursor.indexOfShot
        cell.setSelected(isCurrentShooter && isCurrentShot)
        
        return cell
    }
    
}

extension ScoreViewController: UICollectionViewDelegate {
    
    // Scroll all collection views in unison.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? ScoreCollectionView {
            let indexOfScrollView = collectionView.indexOfAthlete!
            let contentOffset = collectionView.contentOffset
            for i in 0 ..< self.competingAthletes.count {
                if i != indexOfScrollView {
                    self.tableViewCells[i].collectionView.contentOffset = contentOffset
                }
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let collectionView = scrollView as? ScoreCollectionView,
            let numberOfPostsCompleted = collectionView.indexPathForItem(at: targetContentOffset.pointee)?.section {
            self.updateStationLabels(with: numberOfPostsCompleted)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let indexOfShooter = (collectionView as! ScoreCollectionView).indexOfAthlete!
        let indexOfShot = indexPath.section * Skeet.numberOfShotsPerStation + indexPath.item
        self.moveCursor(toIndexOfShooter: indexOfShooter, indexOfShot: indexOfShot)
    }
    
}

extension ScoreViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return ScoreCollectionView.inset(for: self.tableView, forSectionAt: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideLength = ScoreCollectionView.cellSideLength(for: self.tableView)
        return CGSize(square: sideLength)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ScoreCollectionView.interItemSpacing(for: self.tableView)
    }
    
}
