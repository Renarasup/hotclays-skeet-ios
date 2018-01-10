//
//  SheetTableViewController.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/5/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import MessageUI
import UIKit

class SheetTableViewController: UITableViewController {

    var sheet: Sheet?
    /// Rounds on the sheet being presented. Sorted in order of increasing round number.
    var rounds: [Round]?
    /// Total scores for all athletes.
    private var athleteScores: [(CompetingAthlete?, Int)]?

    @IBAction func pressedShareButton(_ sender: UIBarButtonItem) {
        guard let sheet = self.sheet else {
            return
        }
        if MFMailComposeViewController.canSendMail(),
            let sheetCSV = SheetExporter.csvData(from: sheet) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            // Configure the email fields.
            mailComposer.navigationBar.tintColor = AppColors.orange
            mailComposer.setSubject("HotClays Score Sheet")
            mailComposer.setMessageBody(SheetExporter.emailBody(for: sheet), isHTML: false)
            mailComposer.addAttachmentData(sheetCSV, mimeType: "text/csv", fileName: "HotClays Score Sheet.csv")
            
            // Present the mail composer.
            DispatchQueue.main.async {
                self.present(mailComposer, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Cannot Send Email", message: "This device is not configured to send email. To share sheets, please set up email in your device settings.", preferredStyle: .alert)
            alert.view.tintColor = AppColors.orange
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func pressedEditButton(_ sender: UIBarButtonItem) {
        guard self.sheet != nil else {
            return
        }
        // Create an action sheet, including information for iPad.
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.modalPresentationStyle = .popover
        actionSheet.popoverPresentationController?.barButtonItem = sender
        
        // Create edit and delete options for the action sheet.
        let editSheetAction = UIAlertAction(title: "Edit", style: .default, handler: { _ in self.presentEditSheetViewController() })
        editSheetAction.setValue(AppColors.orange, forKey: "titleTextColor")
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in self.deleteSheet() })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(AppColors.black, forKey: "titleTextColor")
        for action in [editSheetAction, deleteAction, cancelAction] {
            actionSheet.addAction(action)
        }
        
        // Display the action sheet.
        DispatchQueue.main.async {
            self.present(actionSheet, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove top section header.
        self.tableView.contentInset = CommonConstants.insetsToRemoveTopHeader
        
        self.reloadTableViewDataSource()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Sections: Header, Summary, Rounds, Notes.
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return athleteScores?.count ?? 0
        } else if section == 2 {
            return self.rounds?.count ?? 0
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CommonConstants.sheetTableViewCellID) as! SheetTableViewCell
            cell.configure(with: self.sheet, allowSelection: false)
            cell.setSpacing(withExtraSpacingOn: [.top, .bottom])
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: SheetsConstants.sheetSummaryTableViewCellID) as! SheetSummaryTableViewCell
            let indexOfAthlete = indexPath.row
            if let competingAthlete = self.athleteScores?[indexOfAthlete].0 {
                let score = self.athleteScores![indexOfAthlete].1
                cell.configure(with: competingAthlete, totalScore: score)
            } else {
                cell.configureWithoutAthlete()
            }
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CommonConstants.selectableTableViewCellID) as! SelectableTableViewCell
            let roundNumber = self.rounds?[indexPath.row].roundNumber ?? 0
            cell.configure(with: "Round \(roundNumber)")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CommonConstants.notesTableViewCellID) as! NotesTableViewCell
            cell.configure(with: self.sheet?.notes)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            self.performSegue(withIdentifier: SheetsConstants.showRoundSegueID, sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            // Sheet cell: Add extra padding on top and bottom.
            return CommonConstants.sheetTableViewCellHeight + 2 * 4.0
        } else if indexPath.section == 3 {
            // Notes cell.
            return CommonConstants.notesTableViewCellHeight
        } else {
            return SheetsConstants.sheetSummaryTableViewCellHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }

        // Make a section header with 'TITLE' on left. For scores, add 'OUT OF X' on the right.
        let sectionTitleLabel = UILabel()
        if section == 1 {
            sectionTitleLabel.text = "SCORES"
        } else if section == 2 {
            sectionTitleLabel.text = "ROUNDS"
        } else {
            sectionTitleLabel.text = "NOTES"
        }
        sectionTitleLabel.font = ScoreConstants.groupedTableSectionHeaderFont
        sectionTitleLabel.textColor = AppColors.darkGray
        
        // Create label with 'OUT OF X' text for total number of shots in the scores section.
        let outOfXLabel = UILabel()
        outOfXLabel.font = ScoreConstants.groupedTableSectionHeaderFont
        outOfXLabel.textColor = AppColors.darkGray
        let numberOfShots = (self.rounds?.count ?? 0) * Trap.numberOfShotsPerRound
        outOfXLabel.text = (section == 1 && numberOfShots > 0) ? "OUT OF \(numberOfShots)" : nil
        let stackView = UIStackView(arrangedSubviews: [sectionTitleLabel, outOfXLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let headerView = UIView()
        headerView.addSubview(stackView)
        let margin = ScoreConstants.groupedTableSectionHeaderMargin
        
        // Add leading and trailing constraints, and center vertically.
        stackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: margin).isActive = true
        stackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -margin).isActive = true
        stackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return -CommonConstants.insetsToRemoveTopHeader.top
        } else {
            return 30.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SheetsConstants.showRoundSegueID,
            let roundTableViewController = segue.destination as? RoundTableViewController,
            let indexPathForSelectedRow = self.tableView.indexPathForSelectedRow,
            indexPathForSelectedRow.section == 2 {
            roundTableViewController.delegate = self
            roundTableViewController.sheet = self.sheet
            roundTableViewController.round = self.rounds?[indexPathForSelectedRow.row]
        }
    }
    
    internal func reloadTableViewDataSource() {
        guard let sheet = self.sheet else {
            return
        }

        // Extract rounds into a sorted array.
        self.rounds = [Round]()
        let sortByRoundNumber = NSSortDescriptor(key: "roundNumber", ascending: true)
        if let sortedRounds = sheet.rounds?.sortedArray(using: [sortByRoundNumber]) as? [Round] {
            self.rounds!.append(contentsOf: sortedRounds)
        }
        
        // Extract athletes and their total scores into an array, sorted by squad order in first round.
        self.athleteScores = [(CompetingAthlete?, Int)]()
        if let firstSquad = self.rounds?.first?.toCompetingAthletes() {
            self.athleteScores!.append(contentsOf: firstSquad.map({ ($0, 0) }))
            for i in 0..<self.rounds!.count {
                // Go through each round, summing the score for each athlete.
                let competingAthletes = self.rounds![i].toCompetingAthletes()
                for competingAthlete in competingAthletes {
                    if let competingAthlete = competingAthlete,
                        let indexOfAthlete = self.athleteScores!.index(where: { $0.0 == competingAthlete }) {
                        self.athleteScores![indexOfAthlete].1 += competingAthlete.score.numberOfHits
                    }
                }
            }
        }
    }
    
    internal func presentEditSheetViewController() {
        let navigationController = UIStoryboard(name: "Score", bundle: nil).instantiateViewController(withIdentifier: ScoreConstants.editSheetNavigationControllerID) as! UINavigationController
        if let editSheetTableViewController = navigationController.viewControllers.first as? EditSheetTableViewController {
            editSheetTableViewController.delegate = self
            DispatchQueue.main.async {
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    internal func deleteSheet() {
        if let context = self.sheet?.managedObjectContext {
            context.performAndWait {
                context.delete(self.sheet!)
                try? context.save()
            }
        }
        (self.splitViewController as? HCSplitViewController)?.popViewController(animated: true)
    }
    
}

extension SheetTableViewController: EditSheetDelegate {
    
    var date: Date? {
        return self.sheet?.date as Date?
    }
    
    var event: String? {
        return self.sheet?.event
    }
    
    var range: String? {
        return self.sheet?.range
    }
    
    var field: Int? {
        return Int(self.sheet?.field ?? 1)
    }
    
    var notes: String? {
        return self.sheet?.notes
    }
    
    func didAdd(date: Date, event: String, range: String, field: Int, notes: String) {
        // Update and save the sheet.
        if let sheet = self.sheet, let context = sheet.managedObjectContext {
            context.performAndWait {
                sheet.date = date as NSDate
                sheet.event = event
                sheet.range = range
                sheet.field = Int16(field)
                sheet.notes = notes
                try? context.save()
            }
        }
        // Reload the sheet cell at the top of the table, and notes cell at the bottom.
        let indexPathForSheetCell = IndexPath(row: 0, section: 0)
        let indexPathForNotesCell = IndexPath(row: 0, section: 3)
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPathForSheetCell, indexPathForNotesCell], with: .fade)
        }
    }

}

extension SheetTableViewController: EditRoundDelegate {
    
    func didEditRound(withNew competingAthletes: [CompetingAthlete?]) {
        // Reload all rows that might be affected by changing the round.
        self.reloadTableViewDataSource()
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadSections([1, 2], with: .fade)
            self.tableView.endUpdates()
        }
    }
    
    func didDeleteRound() {
        if let indexPathForDeletedRound = self.tableView.indexPathForSelectedRow {
            self.reloadTableViewDataSource()
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPathForDeletedRound], with: .fade)
                self.tableView.reloadData()
                self.tableView.endUpdates()
            }
        } else {
            // Can't find selected round, so pop to root view controller to avoid displaying stale information.
            (self.splitViewController as? HCSplitViewController)?.popToRootViewController(animated: true)
        }
    }
    
}

extension SheetTableViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
