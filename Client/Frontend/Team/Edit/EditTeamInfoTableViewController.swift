//
//  EditTeamInfoTableViewController.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/7/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class EditTeamInfoTableViewController: UITableViewController {

    @IBOutlet weak var teamNameTextField: UITextField!
    @IBOutlet weak var teamLocationTextField: UITextField!

    var delegate: EditTeamInfoDelegate!

    @IBAction func pressedCancelButton(_ sender: UIBarButtonItem) {
        self.dismiss()
    }
    
    @IBAction func pressedDoneButton(_ sender: UIBarButtonItem) {
        if let teamName = self.teamNameTextField.text,
            let location = self.teamLocationTextField.text,
            teamName.count > 0 && location.count > 0 {
            self.delegate.didSelect(teamName: teamName, teamLocation: location)
            self.dismiss()
        } else {
            let alert = UIAlertController(title: "Empty Name or Location",
                                          message: "Please specify a team name and location.",
                                          preferredStyle: .alert)
            alert.view.tintColor = AppColors.orange
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        if let teamName = UserDefaults.standard.string(forKey: UserDefaultsKeys.teamName) {
            self.teamNameTextField.text = teamName
        }
        if let teamLocation = UserDefaults.standard.string(forKey: UserDefaultsKeys.teamLocation) {
            self.teamLocationTextField.text = teamLocation
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.teamNameTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.teamNameTextField.resignFirstResponder()
        self.teamLocationTextField.resignFirstResponder()
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    private func dismiss() {
        DispatchQueue.main.async {
            self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }

}
