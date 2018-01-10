//
//  EditSquadTableViewController.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import CoreData
import UIKit

class EditSquadTableViewController: UITableViewControllerWithNSFRC {
    
    var athletes: [Athlete]!
    var delegate: EditSquadDelegate!
    lazy var fetchedResultsController: NSFetchedResultsController<Athlete> = {
        // Build up request for all Athletes, sorted by name.
        let request: NSFetchRequest<Athlete> = Athlete.fetchRequest()
        let sortByLastName = NSSortDescriptor(key: "lastName", ascending: true)
        let sortByFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        request.sortDescriptors = [sortByLastName, sortByFirstName]

        // Execute an initial fetch.
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: CoreDataManager.shared.managedObjectContext,
                                             sectionNameKeyPath: "firstLetterOfLastName",
                                             cacheName: nil)
        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()
    
    @IBAction func pressedCancelButton(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func pressedDoneButton(_ sender: UIBarButtonItem) {
        self.delegate.didSelect(self.athletes)
        DispatchQueue.main.async {
            self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func presentNewAthleteViewController() {
        if let navigationController = UIStoryboard(name: "Team", bundle: nil).instantiateViewController(withIdentifier: TeamConstants.addAthleteNavigationControllerID) as? UINavigationController,
            let addAthleteTableViewController = navigationController.viewControllers.first as? AddAthleteTableViewController {
            addAthleteTableViewController.delegate = self
            addAthleteTableViewController.shouldAddAthleteToTeam = false
            
            DispatchQueue.main.async {
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add a footer for adding a new athlete.
        let footerCell = self.tableView.dequeueReusableCell(withIdentifier: SheetsConstants.newAthleteTableViewCellID) as! SelectableTableViewCell
        footerCell.configure(with: "New Athlete")
        let tapForNewAthlete = UITapGestureRecognizer(target: self, action: #selector(presentNewAthleteViewController))
        footerCell.contentView.addGestureRecognizer(tapForNewAthlete)
        footerCell.contentView.addBorder(toEdges: [.top, .bottom],
                                         withColor: CommonConstants.tableViewCellSeparatorColor,
                                         thickness: 1.0 / UIScreen.main.scale)
        self.tableView.tableFooterView = footerCell.contentView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Add athlete to the squad if there's room.
        if self.athletes.count < Station.allValues.count {
            let athlete = fetchedResultsController.object(at: indexPath)
            self.athletes.append(athlete)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Remove athlete from the squad.
        let athlete = fetchedResultsController.object(at: indexPath)
        if let index = self.athletes.index(of: athlete) {
            self.athletes.remove(at: index)
        }
    }
    
    // MARK: UITableViewDataSource Implementation
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableViewParameter: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewParameter.dequeueReusableCell(withIdentifier: CommonConstants.selectableTableViewCellID) as! SelectableTableViewCell
        let athlete = self.fetchedResultsController.object(at: indexPath)
        cell.configure(with: String(describing: athlete))

        // Set selected if the shooter is already included in this round.
        if self.athletes.contains(athlete) {
            // Note: Renamed first argument to tableViewParameter to avoid conflict here
            tableViewParameter.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CommonConstants.selectableTableViewCellHeight
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return CommonConstants.alphabeticalSectionTitles
    }

    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return CommonConstants.alphabeticalSectionTitles.index(of: title) ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.fetchedResultsController.sections?[section].name
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == self.tableView.numberOfSections - 1 ? 30.0 : 0.0001
    }

    override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .update {
            if let indexPath = indexPath,
                let cell = self.tableView.cellForRow(at: indexPath) as? SelectableTableViewCell,
                let athlete = anObject as? Athlete {
                cell.configure(with: String(describing: athlete))
            }
        } else {
            super.controller(controller, didChange: anObject, at: indexPath, for: type, newIndexPath: newIndexPath)
        }
    }

}

extension EditSquadTableViewController: AddAthleteDelegate {

    func didAdd(_ athlete: Athlete) {
        // Select the athlete that was just added.
        if let indexPath = self.fetchedResultsController.indexPath(forObject: athlete) {
            DispatchQueue.main.async {
                self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                self.tableView(self.tableView, didSelectRowAt: indexPath)
            }
        }
    }

}
