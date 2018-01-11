//
//  RoundTableViewController+UICollectionViewExtensions.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/7/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

extension RoundTableViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Skeet.numberOfShotsPerStation
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Station.allValues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let indexOfAthlete = (collectionView as! ScoreCollectionView).indexOfAthlete!
        let indexOfShot = indexPath.section * Skeet.numberOfShotsPerStation + indexPath.item
        let shot = self.competingAthletes[indexOfAthlete]?.score.getShot(atIndex: indexOfShot) ?? .notTaken
        
        let cell: ScoreCollectionViewCell
        if shot == .notTaken {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommonConstants.notTakenScoreCollectionViewCellID, for: indexPath) as! NotTakenScoreCollectionViewCell
        } else if shot == .hit {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommonConstants.hitScoreCollectionViewCellID, for: indexPath) as! HitScoreCollectionViewCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommonConstants.missScoreCollectionViewCellID, for: indexPath) as! MissScoreCollectionViewCell
        }
        
        return cell
    }
    
}

extension RoundTableViewController: UICollectionViewDelegate {
    
    // Scroll all collection views in unison.
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? ScoreCollectionView {
            let indexOfScrollView = collectionView.indexOfAthlete!
            let contentOffset = collectionView.contentOffset
            for i in 0 ..< self.competingAthletes.count {
                if i != indexOfScrollView {
                    self.scoreTableViewCells[i].collectionView.contentOffset = contentOffset
                }
            }
        }
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let collectionView = scrollView as? ScoreCollectionView,
            let numberOfPostsCompleted = collectionView.indexPathForItem(at: targetContentOffset.pointee)?.section {
            self.updateStationLabels(with: numberOfPostsCompleted)
        }
    }
    
}

extension RoundTableViewController: UICollectionViewDelegateFlowLayout {
    
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
