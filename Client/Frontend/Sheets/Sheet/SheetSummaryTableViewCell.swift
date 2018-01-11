//
//  SheetSummaryTableViewCell.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/7/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class SheetSummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var athleteLabel: UILabel!
    @IBOutlet weak var athleteDetailsLabel: UILabel!
    @IBOutlet weak var totalScoreLabel: UILabel!
    @IBOutlet weak var totalScoreView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.totalScoreView.layer.cornerRadius = SheetsConstants.sheetSummaryCellScoreCornerRadius
    }

    func configure(with competingAthlete: CompetingAthlete, totalScore: Int) {
        self.athleteLabel.text = competingAthlete.fullName
        self.athleteLabel.textColor = AppColors.black
        self.athleteDetailsLabel.text = String(describing: competingAthlete.gauge)
        self.totalScoreLabel.text = "\(totalScore)"
    }

    func configureWithoutAthlete() {
        self.athleteLabel.text = "No Athlete"
        self.athleteLabel.textColor = AppColors.darkGray
        self.athleteDetailsLabel.text = "-"
        self.totalScoreLabel.text = "-"
    }

}
