//
//  RoundTableViewController+UICollectionViewExtensions.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/7/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

extension RoundTableViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Station.allValues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Each section represents a station
        let station = Station(rawValue: Int16(section + 1))!
        return station.numberOfShots
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Get the shot to display (i.e., hit, miss, or none if not yet attempted).
        let indexOfAthlete = (collectionView as! ScoreCollectionView).indexOfAthlete!
        let indexOfShot = Station.indexOfShot(from: indexPath)
        let shot = self.competingAthletes[indexOfAthlete].score.getShot(atIndex: indexOfShot)
        
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
            let superview = collectionView.outermostSuperview {
            // Compute offset for first center cell (cannot simply take the leftmost cell, because that doesn't work for a 2-shot station)
            var centerCellOffset = targetContentOffset.pointee
            centerCellOffset.x += ScoreCollectionView.interItemSpacing(for: superview) + ScoreCollectionView.cellSideLength(for: superview)
            
            // Compute section index based on center 
            if let numberOfPostsCompleted = collectionView.indexPathForItem(at: centerCellOffset)?.section {
                self.updateStationLabels(with: numberOfPostsCompleted)
            }
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
