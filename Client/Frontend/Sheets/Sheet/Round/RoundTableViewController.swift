//
//  RoundTableViewController.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/7/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import MessageUI
import UIKit

class RoundTableViewController: UITableViewController {

    @IBOutlet weak var stationIndicator: UIPageControl!

    var delegate: EditRoundDelegate!
    var sheet: Sheet!
    var round: Round!
    var competingAthletes: [CompetingAthlete]!

    internal var scoreTableViewCells = [ScoreTableViewCell]()
    internal var stationLabels = [UILabel]()

    @IBAction func pressedShareButton(_ sender: UIBarButtonItem) {
        if MFMailComposeViewController.canSendMail(),
            let roundCSV = RoundExporter.csvData(from: round) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            // Configure the email fields.
            mailComposer.navigationBar.tintColor = AppColors.orange
            mailComposer.setSubject("HotClays Skeet Round")
            mailComposer.setMessageBody(RoundExporter.emailBody(for: round), isHTML: false)
            mailComposer.addAttachmentData(roundCSV, mimeType: "text/csv", fileName: "HotClays Skeet Round.csv")
            
            // Present the mail composer.
            DispatchQueue.main.async {
                self.present(mailComposer, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Cannot Send Email", message: "This device is not configured to send email. To share rounds, please set up email in your device settings.", preferredStyle: .alert)
            alert.view.tintColor = AppColors.orange
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func pressedEditButton(_ sender: UIBarButtonItem) {
        // Create an action sheet, including information for iPad.
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.modalPresentationStyle = .popover
        actionSheet.popoverPresentationController?.barButtonItem = sender
        
        // Create edit and delete options for the action sheet.
        let editAction = UIAlertAction(title: "Edit", style: .default, handler: { _ in self.presentEditRoundViewController() })
        editAction.setValue(AppColors.orange, forKey: "titleTextColor")
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in self.deleteRound() })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(AppColors.black, forKey: "titleTextColor")
        for action in [editAction, deleteAction, cancelAction] {
            actionSheet.addAction(action)
        }
        
        // Display the action sheet.
        DispatchQueue.main.async {
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    @objc func stationIndicatorValueChanged(_ sender: UIPageControl) {
        // Scroll all collection views to the page control's current page.
        if let collectionView = scoreTableViewCells.first?.collectionView as? ScoreCollectionView {
            let indexPath = IndexPath(item: 0, section: sender.currentPage)
            collectionView.scrollToStation(at: indexPath, animated: true)
            self.updateStationLabels(with: sender.currentPage)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove top section header.
        self.tableView.contentInset = CommonConstants.insetsToRemoveTopHeader
        
        // Configure the UI.
        self.reloadTableViewDataSource()
        
        // Listen for taps on the station indicator control.
        self.stationIndicator.addTarget(self, action: #selector(stationIndicatorValueChanged(_:)), for: .valueChanged)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Sections: Header, one section per station.
        return 1 + self.competingAthletes.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CommonConstants.sheetTableViewCellID) as! SheetTableViewCell
            cell.configure(with: self.sheet, allowSelection: false, forRound: self.round.roundNumber)
            cell.setSpacing(withExtraSpacingOn: [.top, .bottom])
            return cell
        } else {
            let indexOfAthlete = indexPath.section - 1
            let cell = self.scoreTableViewCells[indexOfAthlete]
            let athlete = self.competingAthletes[indexOfAthlete]
            cell.configure(with: athlete.score, at: indexOfAthlete, isTakingOption: false)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        // Make a section header with shooter name on the left, and current post on the right.
        let indexOfAthlete = section - 1
        let fullNameLabel = UILabel()
        fullNameLabel.text = self.competingAthletes[indexOfAthlete].fullName.uppercased()
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            // Sheet cell: Add extra padding on top and bottom.
            return CommonConstants.sheetTableViewCellHeight + 2 * 4.0
        } else {
            return ScoreTableViewCell.heightForRow(for: self.tableView)
        }
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
    
    /// Update all station labels and the post indicator when scrolling horizontally.
    ///
    /// - Parameter numberOfStationsCompleted: Number of posts completed, used to set the post labels.
    internal func updateStationLabels(with numberOfStationsCompleted: Int) {
        for indexOfAthlete in 0..<self.competingAthletes.count {
            let currentStation = Station.one.next(advancingBy: numberOfStationsCompleted)
            self.stationLabels[indexOfAthlete].text = currentStation.description.uppercased()
        }
        self.stationIndicator.currentPage = numberOfStationsCompleted
    }
    
    /// Reload all data structures used to populate the view controller's table view.
    private func reloadTableViewDataSource() {
        // Extract competing athletes.
        self.competingAthletes = self.round.toCompetingAthletes()
        
        // Preload the station labels displayed in each section header.
        for _ in self.competingAthletes {
            let stationLabel = UILabel()
            stationLabel.textAlignment = .right
            stationLabel.text = Station.one.description.uppercased()
            stationLabel.font = ScoreConstants.groupedTableSectionHeaderFont
            stationLabel.textColor = AppColors.darkGray
            self.stationLabels.append(stationLabel)
        }
        
        // Preload the table view cells.
        for _ in 0..<self.competingAthletes.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: CommonConstants.scoreTableViewCellID) as! ScoreTableViewCell
            self.scoreTableViewCells.append(cell)
        }
    }
    
    private func presentEditRoundViewController() {
        if let navigationController = UIStoryboard(name: "Score", bundle: nil).instantiateViewController(withIdentifier: ScoreConstants.scoreNavigationControllerID) as? UINavigationController,
            let scoreViewController = navigationController.viewControllers.first as? ScoreViewController {
            scoreViewController.competingAthletes = self.competingAthletes
            scoreViewController.editRoundDelegate = self
            DispatchQueue.main.async {
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    private func deleteRound() {
        let shouldDeleteSheet = self.sheet.rounds?.count == 1
        if let context = self.round.managedObjectContext {
            context.performAndWait {
                if shouldDeleteSheet {
                    context.delete(self.sheet)
                } else {
                    context.delete(self.round)
                }
                try? context.save()
            }
        }
        if shouldDeleteSheet {
            // If we deleted the whole sheet, pop all the way to root.
            (self.splitViewController as? HCSplitViewController)?.popToRootViewController(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

extension RoundTableViewController: EditRoundDelegate {
    
    func didEditRound(withNew competingAthletes: [CompetingAthlete]) {
        // Update the selected round.
        self.round.update(withNew: competingAthletes)

        // Reload all table view rows.
        self.reloadTableViewDataSource()
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadData()
            self.tableView.endUpdates()
        }
        
        // Reload all scores.
        DispatchQueue.main.async {
            for scoreTableViewCell in self.scoreTableViewCells {
                scoreTableViewCell.collectionView.reloadData()
            }
        }

        // Pass back the update to the delegate SheetTableViewController.
        self.delegate.didEditRound(withNew: competingAthletes)
    }
    
    func didDeleteRound() {
        fatalError("RoundTableViewController didDeleteRound() delegate method invoked.")
    }
    
}

extension RoundTableViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

