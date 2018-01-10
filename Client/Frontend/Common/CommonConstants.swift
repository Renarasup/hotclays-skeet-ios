//
//  CommonConstants.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class CommonConstants {
    
    /// Corner radius for buttons
    static let buttonCornerRadius = CGFloat(7.0)
    
    /// Corner radius for collection view cells in a score.
    static let scoreCellCornerRadius = UIDevice.current.userInterfaceIdiom == .pad ? CGFloat(10.0) : CGFloat(5.0)
    
    /// Line width of the stroke for a 'Hit' slash or 'Miss' circle.
    static let shotIndicatorStrokeLineWidth = CGFloat(2.5)
    
    /// Scale of shot indicator within a `*ScoreCollectionViewCell`.
    static let shotIndicatorScale = CGFloat(0.6)
    
    /// Color of the stroke for a `Hit` slash or `Miss` circle.
    static let shotIndicatorColor = AppColors.black
    
    // Score Collection View Cell IDs
    static let hitScoreCollectionViewCellID = "hitScoreCollectionViewCellID"
    static let missScoreCollectionViewCellID = "missScoreCollectionViewCellID"
    static let notTakenScoreCollectionViewCellID = "notTakenScoreCollectionViewCellID"
    
    /// Border width of `*ScoreCollectionViewCell` when selected.
    static let scoreCellSelectedBorderWidth = CGFloat(2.0)
    
    /// Maximum width for `ScoreCollectionView`'s containing stack view.
    static let scoreCollectionViewMaximumWidth = CGFloat(745.0)
    
    /// Storyboard ID for a `ScoreTableViewCell`.
    static let scoreTableViewCellID = "scoreTableViewCellID"
    
    /// Storyboard ID for a `SheetTableViewCell`.
    static let sheetTableViewCellID = "sheetTableViewCellID"
    
    /// Storyboard ID for a `SelectableTableViewCell`.
    static let selectableTableViewCellID = "selectableTableViewCellID"
    static let selectableTableViewCellHeight = CGFloat(55.0)
    
    static let notesTableViewCellID = "notesTableViewCellID"
    static let notesTableViewCellHeight = CGFloat(150)
    
    /// Height for a `SheetTableViewCell`.
    static let sheetTableViewCellHeight = CGFloat(112.0)
    static let sheetTableViewCellCornerRadius = CGFloat(5.0)
    static let sheetTableViewCellBackgroundColor = UIColor(hex: 0xEBEBF1)
    static let sheetTableViewCellSelectedBackdropColor = UIColor(hex: 0xF0F1F1)
    static let sheetTableViewCellBorderColor = UIColor(hex: 0xE4E4E4).cgColor
    
    /// Default separator color for a `UITableViewCell`.
    static let tableViewCellSeparatorColor = UIColor(hex: 0xC8C7CC)
    
    /// Insets to remove the top header separator line in a grouped `UITableView`.
    static let insetsToRemoveTopHeader = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
    
    // Section Index Titles for Alphabetical by First Letter
    static let alphabeticalSectionTitles = ["#", "A", "B", "C", "D", "E", "F", "G", "H",
                                            "I", "J", "K", "L", "M", "N", "O", "P", "Q",
                                            "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
}
