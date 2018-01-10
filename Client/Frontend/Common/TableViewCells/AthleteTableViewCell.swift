//
//  AthleteTableViewCell.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class AthleteTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    func configure(with athlete: Athlete) {
        self.nameLabel.text = String(describing: athlete)
        self.nameLabel.textColor = AppColors.orange
        
        if let defaultGauge = Gauge(rawValue: athlete.defaultGauge),
            let defaultYardage = Yardage(rawValue: athlete.defaultYardage) {
            self.infoLabel.text = "\(defaultGauge.description) | \(defaultYardage.description)"
        } else {
            self.infoLabel.text = nil
        }
    }

    func configure(with competingAthlete: CompetingAthlete) {
        self.nameLabel.text = competingAthlete.fullName
        self.nameLabel.textColor = AppColors.black
        let infoComponents = [
            String(describing: competingAthlete.firstStation),
            String(describing: competingAthlete.gauge),
            String(describing: competingAthlete.yardage)]
        self.infoLabel.text = infoComponents.joined(separator: " | ")
    }

    func configureWithoutAthlete(for station: Station) {
        self.nameLabel.text = "No Athlete"
        self.nameLabel.textColor = AppColors.darkGray
        self.infoLabel.text = String(describing: station)
    }
    
}
