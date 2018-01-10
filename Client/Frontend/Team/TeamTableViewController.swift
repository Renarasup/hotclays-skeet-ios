//
//  TeamTableViewController.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import CoreData
import UIKit

class TeamTableViewController: UITableViewControllerWithNSFRC {

    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var teamLocationLabel: UILabel!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Athlete> = {
        // Build up request for all Athletes, sorted by name.
        let request: NSFetchRequest<Athlete> = Athlete.fetchRequest()
        let sortByFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        let sortByLastName = NSSortDescriptor(key: "lastName", ascending: true)
        request.sortDescriptors = [sortByLastName, sortByFirstName]
        request.predicate = NSPredicate(format: "isOnTeam == %@", NSNumber(booleanLiteral: true))

        // Execute an initial fetch.
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: CoreDataManager.shared.managedObjectContext,
                                             sectionNameKeyPath: "firstLetterOfLastName",
                                             cacheName: nil)
        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()
    
    /// Reveal an action sheet when the user taps the 'Edit' bar button item.
    @IBAction func pressedEditButton(_ sender: UIBarButtonItem) {
        if self.tableView.isEditing {
            // Edit button is actually "Done" button to finish editing.
            if self.tableView.isEditing {
                self.tableView.setEditing(false, animated: true)
            }
            if let doneButton = self.navigationItem.leftBarButtonItem {
                doneButton.title = "Edit"
                doneButton.style = .plain
            }
        } else {
            // Construct actions to place in an action sheet.
            let editTeamInfoAction = UIAlertAction(title: "Edit Team Info", style: .default, handler: { (action) in self.presentEditTeamInfoViewController() })
            editTeamInfoAction.setValue(AppColors.orange, forKey: "titleTextColor")
            let editAthletesAction = UIAlertAction(title: "Edit Athletes", style: .default, handler: { (action) in self.editAthletes() })
            editAthletesAction.setValue(AppColors.orange, forKey: "titleTextColor")
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            cancelAction.setValue(AppColors.black, forKey: "titleTextColor")
            
            // Construct the action sheet, including information for iPad.
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.modalPresentationStyle = .popover
            actionSheet.popoverPresentationController?.barButtonItem = sender
            for action in [editTeamInfoAction, editAthletesAction, cancelAction] {
                actionSheet.addAction(action)
            }
            
            // Display the action sheet.
            DispatchQueue.main.async {
                self.present(actionSheet, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func pressedAddButton(_ sender: UIBarButtonItem) {
        self.presentAddAthleteViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
        
        // Configure the header view.
        self.tableView.tableHeaderView?.addBorder(toEdges: [.bottom],
                                                  withColor: CommonConstants.tableViewCellSeparatorColor,
                                                  thickness: 1.0 / UIScreen.main.scale)
        self.configureHeaderView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommonConstants.selectableTableViewCellID) as! SelectableTableViewCell
        let athlete = self.fetchedResultsController.object(at: indexPath)
        cell.configure(with: "\(athlete.firstName ?? "") \(athlete.lastName ?? "")")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CommonConstants.selectableTableViewCellHeight
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.fetchedResultsController.sections?[section].name
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .update {
            if let indexPath = indexPath,
                let cell = self.tableView.cellForRow(at: indexPath) as? SelectableTableViewCell,
                let athlete = anObject as? Athlete {
                cell.configure(with: "\(athlete.firstName ?? "") \(athlete.lastName ?? "")")
            }
        } else {
            super.controller(controller, didChange: anObject, at: indexPath, for: type, newIndexPath: newIndexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Handle the case where master-detail shown side-by-side, and we delete the athlete shown in detail.
            if let indexPathForSelectedRow = tableView.indexPathForSelectedRow,
                indexPathForSelectedRow == indexPath {
                DispatchQueue.main.async {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                    self.performSegue(withIdentifier: TeamConstants.showDetailSegueID, sender: self)
                }
            }
            
            // Delete the athlete.
            let athlete = self.fetchedResultsController.object(at: indexPath)
            CoreDataManager.shared.managedObjectContext.delete(athlete)
            CoreDataManager.shared.saveContext()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == TeamConstants.showDetailSegueID,
            let navigationController = segue.destination as? UINavigationController,
            let athleteTableViewController = navigationController.viewControllers.first as? AthleteTableViewController {
            if let indexPathForSelectedRow = self.tableView.indexPathForSelectedRow {
                let athlete = self.fetchedResultsController.object(at: indexPathForSelectedRow)
                athleteTableViewController.athlete = athlete
            } else {
                athleteTableViewController.athlete = nil
            }
        }
    }

    internal func configureHeaderView() {
        if let teamName = UserDefaults.standard.string(forKey: UserDefaultsKeys.teamName) {
            self.teamNameLabel.text = teamName
            self.teamNameLabel.textColor = AppColors.orange
        } else {
            self.teamNameLabel.text = "No Team"
            self.teamNameLabel.textColor = AppColors.darkGray
        }
        if let teamLocation = UserDefaults.standard.string(forKey: UserDefaultsKeys.teamLocation) {
            self.teamLocationLabel.text = teamLocation
        } else {
            self.teamLocationLabel.text = "No Location"
        }
    }
    
    private func presentAddAthleteViewController() {
        if let navigationController = UIStoryboard(name: "Team", bundle: nil).instantiateViewController(withIdentifier: TeamConstants.addAthleteNavigationControllerID) as? UINavigationController,
            let addAthleteTableViewController = navigationController.viewControllers.first as? AddAthleteTableViewController {
            addAthleteTableViewController.delegate = self
            addAthleteTableViewController.shouldAddAthleteToTeam = true
            
            DispatchQueue.main.async {
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    private func editAthletes() {
        // Set tableView to editing. Maintain selection in case selected row gets deleted.
        let indexPathForSelectedRow = self.tableView.indexPathForSelectedRow
        self.tableView.setEditing(true, animated: true)
        if indexPathForSelectedRow != nil {
            self.tableView.selectRow(at: indexPathForSelectedRow!, animated: false, scrollPosition: .none)
        }
        
        if let editButton = self.navigationItem.leftBarButtonItem {
            editButton.title = "Done"
            editButton.style = .done
        }
    }
    
    private func presentEditTeamInfoViewController() {
        let navigationController = UIStoryboard(name: "Team", bundle: nil).instantiateViewController(withIdentifier: TeamConstants.editTeamInfoNavigationControllerID) as! UINavigationController
        if let editTeamInfoTableViewController = navigationController.viewControllers.first as? EditTeamInfoTableViewController {
            editTeamInfoTableViewController.delegate = self
        }
        DispatchQueue.main.async {
            self.present(navigationController, animated: true, completion: nil)
        }
    }

}

extension TeamTableViewController: AddAthleteDelegate {
    
    func didAdd(_ athlete: Athlete) {
        // Updates handled by the fetched results controller.
    }
    
}

extension TeamTableViewController: EditTeamInfoDelegate {

    func didSelect(teamName: String, teamLocation: String) {
        // Store the team name and location.
        UserDefaults.standard.set(teamName, forKey: UserDefaultsKeys.teamName)
        UserDefaults.standard.set(teamLocation, forKey: UserDefaultsKeys.teamLocation)
        // Update the header.
        self.configureHeaderView()
    }

}


