//
//  AddAthleteTableViewController.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class AddAthleteTableViewController: UITableViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    var delegate: AddAthleteDelegate!
    
    /// Whether the view controller should add the athlete to the current user's team.
    var shouldAddAthleteToTeam = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Footer displays a warning that athlete will not be added to the team.
        self.tableView.tableFooterView?.isHidden = self.shouldAddAthleteToTeam
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.firstNameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.firstNameTextField.resignFirstResponder()
        self.lastNameTextField.resignFirstResponder()
    }
    
    @IBAction func pressedCancelButton(_ sender: UIBarButtonItem) {
        self.dismiss()
    }
    
    @IBAction func pressedDoneButton(_ sender: UIBarButtonItem) {
        guard let firstName = self.firstNameTextField.text?.capitalized,
            firstName.count > 0
                && !firstName.contains(Character(","))
                && !firstName.contains(Character(";")) else {
                    self.presentAlert(title: "Invalid First Name", message: "Please enter a non-empty first name (cannot contain commas or semicolons).")
                    return
        }
        guard let lastName = self.lastNameTextField.text?.capitalized,
            lastName.count > 0
                && !lastName.contains(Character(","))
                && !lastName.contains(Character(";")) else {
                    self.presentAlert(title: "Invalid Last Name", message: "Please enter a non-empty last name (cannot contain commas or semicolons).")
                    return
        }
        
        let athlete = Athlete.getOrInsert(firstName: firstName, lastName: lastName)
        // Make sure athlete is on the team if `shouldAddAthleteToTeam` is true.
        if self.shouldAddAthleteToTeam && athlete.isOnTeam == false {
            athlete.managedObjectContext?.performAndWait {
                athlete.isOnTeam = true
                try? athlete.managedObjectContext?.save()
            }
        }
        self.delegate.didAdd(athlete)
        
        self.dismiss()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    /// Present an error `UIAlertController` with the given title and message.
    /// Add 'OK' as the only action.
    ///
    /// - Parameters:
    ///   - title: Title of the alert.
    ///   - message: Message in the alert.
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = AppColors.orange
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    /// Dismiss this view controller.
    private func dismiss() {
        DispatchQueue.main.async {
            self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }

}
