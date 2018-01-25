//
//  ChooseSheetTableViewController.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/10/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import CoreData
import UIKit

/// View controller for selecting an existing sheet in `SetupTableViewController`.
class ChooseSheetTableViewController: UITableViewControllerWithNSFRC {

    var delegate: EditSheetDelegate!
    lazy var fetchedResultsController: NSFetchedResultsController<Sheet> = {
        // Build up request for all sheets, sorted by date (most recent first).
        let request: NSFetchRequest<Sheet> = Sheet.fetchRequest()
        let sortByDate = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortByDate]
        
        // Execute an initial fetch.
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: CoreDataManager.shared.managedObjectContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()
    
    
    @IBAction func pressedCancelButton(_ sender: UIBarButtonItem) {
        self.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Insets to make top and bottom spacing match inter-cell spacing.
        self.tableView.contentInset = UIEdgeInsetsMake(4.0, 0.0, 4.0, 0.0)
        self.clearsSelectionOnViewWillAppear = true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommonConstants.sheetTableViewCellID) as! SheetTableViewCell
        let sheet = self.fetchedResultsController.object(at: indexPath)
        cell.configure(with: sheet, allowSelection: true)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sheet = self.fetchedResultsController.object(at: indexPath)
        if let date = sheet.date as Date?, let event = sheet.event, let range = sheet.range {
            self.delegate.didAdd(date: date, event: event, range: range, field: sheet.field, notes: sheet.notes ?? "")
        }
        self.dismiss()
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
    
    private func dismiss() {
        DispatchQueue.main.async {
            self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }

}
