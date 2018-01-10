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
    var selectedYardage: Yardage!

    @IBAction func pressedCancelButton(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func pressedDoneButton(_ sender: UIBarButtonItem) {
        self.delegate.didEditAthlete(at: self.indexOfAthlete, gauge: self.selectedGauge, yardage: self.selectedYardage)
        DispatchQueue.main.async {
            self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Sections: Athlete, gauge, yardage
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // Athlete section
            return 1
        } else if section == 1 {
            // Gauge section
            return Gauge.allValues.count
        } else {
            // Yardage section
            return Yardage.allValues.count
        }
    }
    
    override func tableView(_ tableViewParameter: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellDescription: String
        let isSelected: Bool
        if indexPath.section == 0 {
            // Athlete section
            cellDescription = self.athleteName
            isSelected = false
        } else if indexPath.section == 1 {
            // Gauge section
            let gauge = Gauge.allValues[indexPath.row]
            cellDescription = String(describing: gauge)
            isSelected = gauge == self.selectedGauge
        } else {
            // Yardage section
            let yardage = Yardage.allValues[indexPath.row]
            cellDescription = String(describing: yardage)
            isSelected = yardage == self.selectedYardage
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
        } else if section == 1 {
            return "Gauge"
        } else {
            return "Yardage"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Update shooter with new selection, keeping track of old selection.
        var rowOfOldSelection: Int?
        if indexPath.section == 1 {
            // Gauge section
            let gauge = Gauge.allValues[indexPath.row]
            if gauge != self.selectedGauge {
                rowOfOldSelection = Gauge.allValues.index(of: self.selectedGauge)!
                self.selectedGauge = gauge
            }
        } else {
            // Yardage section
            let yardage = Yardage.allValues[indexPath.row]
            if yardage != self.selectedYardage {
                rowOfOldSelection = Yardage.allValues.index(of: self.selectedYardage)!
                self.selectedYardage = yardage
            }
        }
        
        // Deselect the previously selected row in this section
        if let row = rowOfOldSelection {
            let indexPathOfOldSelection = IndexPath(row: row, section: indexPath.section)
            tableView.deselectRow(at: indexPathOfOldSelection, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Allow deselection only if deselecting a cell that is inconsistent with `self.shooter`.
        var allowDeselection = true
        if indexPath.section == 1 {
            let gauge = Gauge.allValues[indexPath.row]
            allowDeselection = gauge != self.selectedGauge
        } else if indexPath.section == 2 {
            let yardage = Yardage.allValues[indexPath.row]
            allowDeselection = yardage != self.selectedYardage
        }
        
        // Disable deselection by re-selecting the cell.
        if !allowDeselection {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
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
