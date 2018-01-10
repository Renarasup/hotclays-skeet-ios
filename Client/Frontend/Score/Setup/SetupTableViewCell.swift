//
//  SetupTableViewCell.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/10/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class SetupTableViewCell: SetupShiftedTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    func configure(with text: String, textColor: UIColor) {
        self.titleLabel.text = text
        self.titleLabel.textColor = textColor
    }

}
