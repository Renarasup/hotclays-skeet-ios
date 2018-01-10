//
//  SheetsTableViewController.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/5/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import CoreData
import UIKit

class SheetsTableViewController: UITableViewControllerWithNSFRC {

    lazy var fetchedResultsController: NSFetchedResultsController<Sheet> = {
        // Build up request for all sheets, sorted by date (most recent first).
        let request: NSFetchRequest<Sheet> = Sheet.fetchRequest()
        let sortByDate = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortByDate]
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

    @IBAction func pressedEditButton(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            // Toggle editing. Maintain selection in case the selected row gets deleted.
            let indexPathForSelectedRow = self.tableView.indexPathForSelectedRow
            self.tableView.setEditing(!self.tableView.isEditing, animated: true)
            if indexPathForSelectedRow != nil {
                self.tableView.selectRow(at: indexPathForSelectedRow!, animated: false, scrollPosition: .none)
            }
            
            // Display 'Done' when editing, and 'Edit' when done.
            sender.title = self.tableView.isEditing ? "Done" : "Edit"
            sender.style = self.tableView.isEditing ? .done : .plain
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Insets to make top and bottom spacing match inter-cell spacing.
        self.tableView.contentInset = UIEdgeInsetsMake(4.0, 0.0, 4.0, 0.0)
        self.clearsSelectionOnViewWillAppear = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the selected sheet to the `SheetTableViewController`.
        if segue.identifier == SheetsConstants.showDetailSegueID,
            let navigationController = segue.destination as? UINavigationController,
            let detailViewController = navigationController.topViewController as? SheetTableViewController {
            if let indexPathForSelectedRow = self.tableView.indexPathForSelectedRow {
                // Load the view with sheets from the selected `SheetSet`.
                let sheet = self.fetchedResultsController.object(at: indexPathForSelectedRow)
                detailViewController.sheet = sheet
            } else {
                detailViewController.sheet = nil
            }
        }
        
        // Tell the split view controller to stop collapsing secondary view controller.
        if let sheetsSplitViewController = self.splitViewController as? HCSplitViewController {
            sheetsSplitViewController.collapseSecondaryViewController = false
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommonConstants.sheetTableViewCellID) as! SheetTableViewCell
        let sheet = self.fetchedResultsController.object(at: indexPath)
        cell.configure(with: sheet, allowSelection: true)
        return cell
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Handle the case where master-detail shown side-by-side, and we delete the sheet shown in detail
            if let indexPathForSelectedRow = tableView.indexPathForSelectedRow,
                indexPathForSelectedRow == indexPath {
                DispatchQueue.main.async {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                    self.performSegue(withIdentifier: SheetsConstants.showDetailSegueID, sender: self)
                }
            }
            
            // Delete the sheet. Fetched results controller delegate methods will reload the UI.
            let sheet = self.fetchedResultsController.object(at: indexPath)
            CoreDataManager.shared.managedObjectContext.performAndWait {
                CoreDataManager.shared.managedObjectContext.delete(sheet)
                CoreDataManager.shared.saveContext()
            }
        }
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
