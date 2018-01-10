//
//  AthleteSheetsTableViewController.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/7/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import CoreData
import UIKit

class AthleteSheetsTableViewController: UITableViewControllerWithNSFRC {

    @IBOutlet weak var athleteNameLabel: UILabel!
    @IBOutlet weak var teamNameLabel: UILabel!

    var athlete: Athlete!
    lazy var fetchedResultsController: NSFetchedResultsController<Sheet> = {
        // Build up request for all sheets, sorted by date (most recent first).
        let request: NSFetchRequest<Sheet> = Sheet.fetchRequest()
        let sortByDate = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortByDate]
        let containsAthlete = NSPredicate(format: "athletes CONTAINS %@", self.athlete)
        request.predicate = containsAthlete
        // Fetch all rounds ahead of time.
        request.relationshipKeyPathsForPrefetching = ["rounds"]
        
        // Execute an initial fetch.
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: CoreDataManager.shared.managedObjectContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Insets to make bottom spacing match inter-cell spacing.
        self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 4.0, 0.0)
        self.clearsSelectionOnViewWillAppear = true

        self.tableView.tableHeaderView?.addBorder(toEdges: [.bottom], withColor: CommonConstants.tableViewCellSeparatorColor, thickness: 1.0 / UIScreen.main.scale)
        self.athleteNameLabel.text = "\(self.athlete.firstName ?? "") \(self.athlete.lastName ?? "")"
        self.teamNameLabel.text = UserDefaults.standard.string(forKey: UserDefaultsKeys.teamName)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommonConstants.sheetTableViewCellID) as! SheetTableViewCell
        let sheet = self.fetchedResultsController.object(at: indexPath)
        cell.configure(with: sheet, allowSelection: true)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let sheetTableViewController = UIStoryboard(name: "Sheets", bundle: nil).instantiateViewController(withIdentifier: SheetsConstants.sheetTableViewControllerID) as? SheetTableViewController {
            let sheet = self.fetchedResultsController.object(at: indexPath)
            sheetTableViewController.sheet = sheet
            self.navigationController?.pushViewController(sheetTableViewController, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CommonConstants.sheetTableViewCellHeight
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Sheets"
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
                let cell = self.tableView.cellForRow(at: indexPath) as? SheetTableViewCell,
                let sheet = anObject as? Sheet {
                cell.configure(with: sheet, allowSelection: true)
            }
        } else {
            super.controller(controller, didChange: anObject, at: indexPath, for: type, newIndexPath: newIndexPath)
        }
    }

}
