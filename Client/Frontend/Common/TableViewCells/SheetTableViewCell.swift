//
//  SheetTableViewCell.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/5/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class SheetTableViewCell: UITableViewCell {

    @IBOutlet weak var backdropViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backdropViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var backdropView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    
    private var allowSelection = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Style the backdrop view
        self.backdropView.clipsToBounds = true
        self.backdropView.layer.cornerRadius = CommonConstants.sheetTableViewCellCornerRadius
        self.backdropView.layer.borderWidth = 1.0
        self.backdropView.layer.borderColor = CommonConstants.sheetTableViewCellBorderColor
    }
    
    func configure(with sheet: Sheet?, allowSelection: Bool, forRound roundNumber: Int16? = nil) {
        self.configure(withEvent: sheet?.event, range: sheet?.range, field: sheet?.field, date: sheet?.date as Date?, allowSelection: allowSelection)
        self.roundLabel.isHidden = false
        if let roundNumber = roundNumber {
            // Configure round label for a specific round.
            self.roundLabel.text = "Round \(roundNumber)"
        } else {
            // Configure round label with the number of rounds.
            if let numberOfRounds = sheet?.rounds?.count {
                let sIfPlural = numberOfRounds != 1 ? "s" : ""
                self.roundLabel.text = "\(numberOfRounds) Round" + sIfPlural
            } else {
                self.roundLabel.text = ""
            }
        }
    }
    
    /// Configure for the `SetupTableViewController` before a `Sheet` has been inserted.
    /// Hide the round label in the top-right corner.
    func configure(withEvent event: String?, range: String?, field: Int16?, date: Date?, allowSelection: Bool) {
        self.allowSelection = allowSelection && event != nil
        if let date = date {
            self.dateLabel.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        } else {
            self.dateLabel.text = ""
        }
        self.eventLabel.text = event ?? ""
        if let range = range {
            if let field = field {
                self.rangeLabel.text = "\(range), Field \(field)"
            } else {
                self.rangeLabel.text = "\(range)"
            }
        } else {
            self.rangeLabel.text = ""
        }
        self.roundLabel.isHidden = true
    }
    
    func setSpacing(withExtraSpacingOn edges: [UIRectEdge]) {
        self.backdropViewTopConstraint.constant = edges.contains(.top) ? 8.0 : 4.0
        self.backdropViewBottomConstraint.constant = edges.contains(.bottom) ? 8.0 : 4.0
    }
    
    internal func setFocused(_ focused: Bool) {
        if focused && self.allowSelection {
            backdropView.backgroundColor = CommonConstants.sheetTableViewCellSelectedBackdropColor
        } else {
            backdropView.backgroundColor = AppColors.white
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        setFocused(selected)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        // Configure the view for the highlighted state
        setFocused(highlighted)
    }

}
