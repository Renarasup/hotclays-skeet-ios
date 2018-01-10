//
//  SetupShiftedTableViewCell.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

/// Cell with a `.disclosureIndicator` accessory view shifted to the left.
/// Necessary because the `SetupShootTableViewController` is always in editing
/// mode, so the disclosure indicator gets shifted to the right. We reverse that
/// shift here.
class SetupShiftedTableViewCell: UITableViewCell {
    
    var accessoryButton: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Save disclosure indicator to adjust its frame later.
        self.accessoryType = .disclosureIndicator
        self.accessoryButton = self.subviews.flatMap({ $0 as? UIButton }).first
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Adjust disclosure indicator frame.
        self.accessoryButton?.frame.origin.x -= 10
    }
    
}
