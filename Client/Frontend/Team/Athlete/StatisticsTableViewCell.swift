//
//  StatisticsTableViewCell.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/7/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class StatisticsTableViewCell: UITableViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!

    func configure(withTitle title: String, average: Double) {
        self.infoLabel.text = title
        self.averageLabel.text = String(format: "%.1f%%", 100.0 * average)
    }

}
