//
//  EditAthleteTableViewController.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/5/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class EditAthleteTableViewController: UITableViewController {

    var delegate: EditAthleteDelegate!
    
    /// Index of athlete in squad.
    var indexOfAthlete: Int!
    var athleteName: String!
    var selectedGauge: Gauge!

    @IBAction func pressedCancelButton(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func pressedDoneButton(_ sender: UIBarButtonItem) {
        self.delegate.didEditAthlete(at: self.indexOfAthlete, gauge: self.selectedGauge)
        DispatchQueue.main.async {
            self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Sections: Athlete, gauge
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // Athlete section
            return 1
        } else {
            // Gauge section
            return Gauge.allValues.count
        }
    }
    
    override func tableView(_ tableViewParameter: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellDescription: String
        let isSelected: Bool
        if indexPath.section == 0 {
            // Athlete section
            cellDescription = self.athleteName
            isSelected = false
        } else {
            // Gauge section
            let gauge = Gauge.allValues[indexPath.row]
            cellDescription = String(describing: gauge)
            isSelected = gauge == self.selectedGauge
        }
        
        let cell: SelectableTableViewCell
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: ScoreConstants.athleteSelectableTableViewCellID) as! SelectableTableViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: CommonConstants.selectableTableViewCellID) as! SelectableTableViewCell
        }
        cell.configure(with: cellDescription)
        if isSelected {
            tableViewParameter.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            tableView(tableViewParameter, didSelectRowAt: indexPath)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Athlete"
        } else {
            return "Gauge"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Update shooter with new selection, keeping track of old selection.
        if indexPath.section == 1 {
            // Gauge section
            let gauge = Gauge.allValues[indexPath.row]
            if gauge != self.selectedGauge {
                let rowOfOldSelection = Gauge.allValues.index(of: self.selectedGauge)!
                self.selectedGauge = gauge
                // Deselect the previously selected row in this section
                let indexPathOfOldSelection = IndexPath(row: rowOfOldSelection, section: indexPath.section)
                tableView.deselectRow(at: indexPathOfOldSelection, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Allow deselection only if deselecting a cell that is inconsistent with `self.shooter`.
        if indexPath.section == 1 {
            let gauge = Gauge.allValues[indexPath.row]
            if gauge != self.selectedGauge {
                // Disable deselection by re-selecting the cell.
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CommonConstants.selectableTableViewCellHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }

}
