//
//  ScoreViewController+UITableViewExtensions.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/5/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit


extension ScoreViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.competingAthletes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indexOfAthlete = indexPath.section
        let cell = self.tableViewCells[indexOfAthlete]
        if let athlete = self.competingAthletes[indexOfAthlete] {
            cell.configure(with: athlete.score, at: indexOfAthlete)
        } else {
            // Fill with nil shots if there's no athlete at a given station.
            cell.configure(with: nil, at: indexOfAthlete)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Make a section header with shooter name on the left, and current post on the right.
        let indexOfAthlete = section
        let fullNameLabel = UILabel()
        fullNameLabel.text = self.competingAthletes[indexOfAthlete]?.fullName.uppercased()
        fullNameLabel.font = ScoreConstants.groupedTableSectionHeaderFont
        fullNameLabel.textColor = AppColors.darkGray
        
        // Store post labels for updating as the score sheet scrolls horizontally.
        let postLabel = self.stationLabels[indexOfAthlete]
        let stackView = UIStackView(arrangedSubviews: [fullNameLabel, postLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let headerView = UIView()
        headerView.addSubview(stackView)
        let margin = ScoreConstants.groupedTableSectionHeaderMargin
        
        // Add leading and trailing constraints, but keep width limited for iPad.
        let leadingAnchorConstraint = stackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: margin)
        leadingAnchorConstraint.priority = .defaultHigh
        leadingAnchorConstraint.isActive = true
        
        let trailingAnchorConstraint = stackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -margin)
        trailingAnchorConstraint.priority = .defaultHigh
        trailingAnchorConstraint.isActive = true
        
        stackView.widthAnchor.constraint(lessThanOrEqualToConstant: CommonConstants.scoreCollectionViewMaximumWidth).isActive = true
        
        stackView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        return headerView
    }
    
}

extension ScoreViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ScoreTableViewCell.heightForRow(for: tableView)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
}
