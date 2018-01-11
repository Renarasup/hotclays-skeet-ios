//
//  SetupTableViewController.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

/// Table view controller for setting up a round of trap.
class SetupTableViewController: UITableViewController {

    // Section number constants.
    let SHEET_SECTION = 0
    let ROUND_SECTION = 1
    let SQUAD_SECTION = 2
    let START_ROUND_SECTION = 3

    internal var competingAthletes = [CompetingAthlete]()
    internal var date: Date?
    internal var event: String?
    internal var range: String?
    internal var field: Int?
    internal var round = 1
    internal var notes: String?
    
    @IBAction func pressedEditButton(_ sender: UIBarButtonItem) {
        // Create an action sheet, including information for iPad.
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.modalPresentationStyle = .popover
        actionSheet.popoverPresentationController?.barButtonItem = sender
        
        // Create edit and delete options for the action sheet.
        let resetAction = UIAlertAction(title: "Reset", style: .default, handler: { _ in self.reset() })
        resetAction.setValue(AppColors.orange, forKey: "titleTextColor")
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(AppColors.black, forKey: "titleTextColor")
        for action in [resetAction, cancelAction] {
            actionSheet.addAction(action)
        }
        
        DispatchQueue.main.async {
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set tableView to editing to allow reordering of shooters.
        self.tableView.setEditing(true, animated: false)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Sections: Sheet, Round, Squad, Start Round.
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SHEET_SECTION {
            // Sheet Section: If there's a sheet, display it. Otherwise, 'Existing Sheet' and 'New Sheet'.
            return self.event != nil ? 1 : 2
        } else if section == SQUAD_SECTION {
            // Squad Section: Cell for each post, plus one for Add Athlete cell.
            return self.competingAthletes.count + 1
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SHEET_SECTION {
            if self.event != nil {
                // Sheet cell
                let sheetCell = tableView.dequeueReusableCell(withIdentifier: CommonConstants.sheetTableViewCellID) as! SheetTableViewCell
                let field: Int16? = self.field == nil ? nil : Int16(self.field!)
                sheetCell.configure(withEvent: self.event, range: self.range, field: field, date: self.date, allowSelection: true)
                return sheetCell
            } else {
                // Add Sheet cell
                let setupCell = tableView.dequeueReusableCell(withIdentifier: ScoreConstants.setupTableViewCellID) as! SetupTableViewCell
                let cellTitle = indexPath.row == 0 ? "Existing Sheet" : "New Sheet"
                setupCell.configure(with: cellTitle, textColor: AppColors.orange)
                return setupCell
            }
        } else if indexPath.section == ROUND_SECTION {
            // Round cell
            let roundNumberCell = tableView.dequeueReusableCell(withIdentifier: ScoreConstants.setupTableViewCellID) as! SetupTableViewCell
            roundNumberCell.configure(with: "Round \(self.round)", textColor: AppColors.black)
            return roundNumberCell
        } else if indexPath.section == SQUAD_SECTION && indexPath.row < self.competingAthletes.count {
            // Athlete cell
            let athleteCell = tableView.dequeueReusableCell(withIdentifier: ScoreConstants.athleteTableViewCellID) as! AthleteTableViewCell
            athleteCell.configure(with: self.competingAthletes[indexPath.row])
            return athleteCell
        } else if indexPath.section == SQUAD_SECTION {
            // Edit Squad cell
            let editSquadCell = tableView.dequeueReusableCell(withIdentifier: ScoreConstants.setupTableViewCellID) as! SetupTableViewCell
            editSquadCell.configure(with: "Edit Squad", textColor: AppColors.orange)
            return editSquadCell
        } else {
            // Start Round cell
            let startRoundCell = tableView.dequeueReusableCell(withIdentifier: ScoreConstants.startRoundTableViewCellID)!
            return startRoundCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Instantiate a navigation controller containing the view controller to present.
        let navigationController: UINavigationController
        
        if indexPath.section == SHEET_SECTION {
            if self.event == nil && indexPath.row == 0 {
                // Existing Sheet: Select from existing sheets.
                navigationController = UIStoryboard(name: "Score", bundle: nil).instantiateViewController(withIdentifier: ScoreConstants.chooseSheetNavigationControllerID) as! UINavigationController
                if let chooseSheetTableViewController = navigationController.viewControllers.first as? ChooseSheetTableViewController {
                    chooseSheetTableViewController.delegate = self
                }
            } else {
                // Sheet or New Sheet cell: Present view controller to edit sheet details.
                navigationController = UIStoryboard(name: "Score", bundle: nil).instantiateViewController(withIdentifier: ScoreConstants.editSheetNavigationControllerID) as! UINavigationController
                if let editSheetTableViewController = navigationController.viewControllers.first as? EditSheetTableViewController {
                    editSheetTableViewController.delegate = self
                }
            }
        } else if indexPath.section == ROUND_SECTION {
            // Round cell: Present view controller to edit round number.
            navigationController = UIStoryboard(name: "Score", bundle: nil).instantiateViewController(withIdentifier: ScoreConstants.editRoundNavigationControllerID) as! UINavigationController
            if let editRoundTableViewController = navigationController.viewControllers.first as? EditRoundNumberTableViewController {
                editRoundTableViewController.delegate = self
                editRoundTableViewController.round = self.round
            }
        } else if indexPath.section == SQUAD_SECTION {
            if indexPath.row < self.competingAthletes.count {
                let competingAthlete = self.competingAthletes[indexPath.row]
                // Selected a row with a valid competing athlete.
                navigationController = UIStoryboard(name: "Score", bundle: nil).instantiateViewController(withIdentifier: ScoreConstants.editAthleteNavigationControllerID) as! UINavigationController
                if let editAthleteTableViewController = navigationController.viewControllers.first as? EditAthleteTableViewController {
                    editAthleteTableViewController.athleteName = competingAthlete.fullName
                    editAthleteTableViewController.delegate = self
                    editAthleteTableViewController.indexOfAthlete = indexPath.row
                    editAthleteTableViewController.selectedGauge = competingAthlete.gauge
                }
            } else {
                // 'Add Athletes' or 'No Athlete' cell: Present view controller to select shooters.
                navigationController = UIStoryboard(name: "Score", bundle: nil).instantiateViewController(withIdentifier: ScoreConstants.addAthletesNavigationControllerID) as! UINavigationController
                if let editSquadTableViewController = navigationController.viewControllers.first as? EditSquadTableViewController {
                    editSquadTableViewController.athletes = self.athletesInSquad()
                    editSquadTableViewController.delegate = self
                }
            }
        } else {
            // 'Start Round' cell: Present view controller to score the round.
            if self.event == nil || self.competingAthletes.count == 0 {
                // Highlight cell user needs to tap to add the necessary information.
                let indexPathOfSuggestedCell = self.event == nil ? IndexPath(row: 0, section: SHEET_SECTION) : IndexPath(row: self.competingAthletes.count, section: SQUAD_SECTION)
                self.tableView.scrollToRow(at: indexPathOfSuggestedCell, at: .none, animated: true)
                self.tableView.selectRow(at: indexPathOfSuggestedCell, animated: true, scrollPosition: .none)
                self.tableView.deselectRow(at: indexPathOfSuggestedCell, animated: true)
                return
            }
            
            navigationController = UIStoryboard(name: "Score", bundle: nil).instantiateViewController(withIdentifier: ScoreConstants.scoreNavigationControllerID) as! UINavigationController
            if let scoreViewController = navigationController.viewControllers.first as? ScoreViewController {
                // Only pass non-nil athletes to the ScoreShootViewController.
                self.competingAthletes.forEach({ $0.resetScore() })
                scoreViewController.scoreDelegate = self
                scoreViewController.competingAthletes = self.competingAthletes
                scoreViewController.date = self.date
                scoreViewController.event = self.event
                scoreViewController.range = self.range
                scoreViewController.field = self.field
                scoreViewController.round = self.round
                scoreViewController.notes = self.notes
            }
        }
        
        // Present the navigation controller containing the view controller to present.
        DispatchQueue.main.async {
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == SHEET_SECTION && self.event != nil {
            return CommonConstants.sheetTableViewCellHeight + 2 * 4.0
        } else if indexPath.section == START_ROUND_SECTION {
            return ScoreConstants.startRoundTableViewCellHeight
        } else {
            return ScoreConstants.setupTableViewCellHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SHEET_SECTION {
            return ScoreConstants.setupSheetSectionTitle
        } else if section == ROUND_SECTION {
            return ScoreConstants.setupRoundSectionTitle
        } else if section == SQUAD_SECTION {
            return ScoreConstants.setupSquadSectionTitle
        } else {
            return nil
        }
    }
    
    // Make the footer size effectively 0.
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    // Resize the header for aesthetics.
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    /// Get an array of `Athlete`s currently in the squad.
    internal func athletesInSquad() -> [Athlete] {
        var athletes = [Athlete]()
        for competingAthlete in self.competingAthletes.flatMap({ $0 }) {
            athletes.append(Athlete.getOrInsert(firstName: competingAthlete.firstName, lastName: competingAthlete.lastName))
        }
        return athletes
    }
    
    
    /// Reset all fields in the `SetupTableViewController`.
    internal func reset() {
        let isClearingSheet = self.event != nil
        self.competingAthletes = [CompetingAthlete]()
        self.date = nil
        self.event = nil
        self.range = nil
        self.field = nil
        self.notes = nil
        self.round = 1
        
        // Reload the table view.
        let indexPathForNewSheet = IndexPath(row: 1, section: SHEET_SECTION)
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            if isClearingSheet {
                self.tableView.insertRows(at: [indexPathForNewSheet], with: .fade)
            }
            self.tableView.reloadData()
            self.tableView.endUpdates()
        }
    }
    
}

// UITableView methods for reordering shooters.
extension SetupTableViewController {
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Allow reordering of shooters.
        return indexPath.section == SQUAD_SECTION && indexPath.row < self.competingAthletes.count
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        // Make sure shooter rows remain in the shooter list.
        if proposedDestinationIndexPath.section < SQUAD_SECTION {
            return IndexPath(row: 0, section: SQUAD_SECTION)
        } else if proposedDestinationIndexPath.section > SQUAD_SECTION
            || proposedDestinationIndexPath.row >= self.competingAthletes.count {
            return IndexPath(row: self.competingAthletes.count - 1, section: SQUAD_SECTION)
        }
        
        return proposedDestinationIndexPath
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Move the shooter in the underlying data source, then update starting posts.
        let shooter = self.competingAthletes.remove(at: sourceIndexPath.row)
        self.competingAthletes.insert(shooter, at: destinationIndexPath.row)
    }
    
}

extension SetupTableViewController: EditSheetDelegate {
    
    func didAdd(date: Date, event: String, range: String, field: Int, notes: String) {
        // Nullify all fields for the sheet details.
        let causesNewSheetRowToBeDeleted = self.event == nil
        self.date = date
        self.event = event
        self.range = range
        self.field = field
        self.notes = notes
        let indexPathForNewSheetCell = IndexPath(row: 1, section: SHEET_SECTION)
        
        // Reset the round to the next available round on this sheet.
        if let sheet = Sheet.get(date: date, event: event, range: range, field: field) {
            let sortByRoundNumber = NSSortDescriptor(key: "roundNumber", ascending: true)
            if let rounds = sheet.rounds?.sortedArray(using: [sortByRoundNumber]) as? [Round],
                let competingAthletes = rounds.first?.toCompetingAthletes() {
                self.competingAthletes = competingAthletes
            }
            self.round = min((sheet.rounds?.count ?? 0) + 1, Sheet.maxNumberOfRounds)
        } else {
            self.round = 1
        }
        
        // Reload the table view.
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            // On first addition of a sheet, section 0 goes from 2 rows to 1 row.
            if causesNewSheetRowToBeDeleted {
                self.tableView.deleteRows(at: [indexPathForNewSheetCell], with: .fade)
            }
            // Reload sheet, round, and shooters.
            self.tableView.reloadData()
            self.tableView.endUpdates()
        }
    }
    
}

extension SetupTableViewController: EditRoundNumberDelegate {
    
    func didSelect(_ round: Int) {
        self.round = round
        let indexPathOfRoundRow = IndexPath(row: 0, section: ROUND_SECTION)
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPathOfRoundRow], with: .fade)
        }
    }
    
}

extension SetupTableViewController: EditSquadDelegate {

    func didSelect(_ athletes: [Athlete]) {
        let oldAthleteCount = self.competingAthletes.count
        let newAthleteCount = athletes.count
        // Add squad members starting from post one.
        self.competingAthletes = athletes.map({ CompetingAthlete(athlete: $0) })
        
        // Reload cells for each athlete in the squad.
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            if oldAthleteCount < newAthleteCount {
                // Insert rows if we increase the athlete count.
                let indexPaths = (oldAthleteCount..<newAthleteCount).map({ IndexPath(row: $0, section: self.SQUAD_SECTION) })
                self.tableView.insertRows(at: indexPaths, with: .fade)
            } else if oldAthleteCount > newAthleteCount {
                // Delete rows if we decrease the athlete count.
                let indexPaths = (newAthleteCount..<oldAthleteCount).map({ IndexPath(row: $0, section: self.SQUAD_SECTION) })
                self.tableView.deleteRows(at: indexPaths, with: .fade)
            }
            // Reload all squad section rows to account for possible reordering.
            self.tableView.reloadSections([self.SQUAD_SECTION], with: .fade)
            self.tableView.endUpdates()
        }
    }

}

extension SetupTableViewController: EditAthleteDelegate {

    func didEditAthlete(at indexOfAthlete: Int, gauge: Gauge) {
        let athlete = self.competingAthletes[indexOfAthlete]
        athlete.gauge = gauge
        let indexPathForAthleteRow = IndexPath(row: indexOfAthlete, section: SQUAD_SECTION)
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPathForAthleteRow], with: .fade)
        }
    }

}

extension SetupTableViewController: ScoreDelegate {

    func didSave(_ sheet: Sheet) {
        self.round = min(self.round + 1, Sheet.maxNumberOfRounds)
        let indexPathForRoundCell = IndexPath(row: 0, section: ROUND_SECTION)
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPathForRoundCell], with: .fade)
        }
    }

}
