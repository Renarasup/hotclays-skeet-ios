//
//  SettingsTableViewController.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/7/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var defaultRangeTextField: UITextField!
    
    override func viewDidLoad() {
        if let defaultRange = UserDefaults.standard.string(forKey: UserDefaultsKeys.defaultRange) {
            self.defaultRangeTextField.text = defaultRange
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let defaultRange = self.defaultRangeTextField.text,
            defaultRange.count > 0 {
            UserDefaults.standard.set(defaultRange, forKey: UserDefaultsKeys.defaultRange)
        } else {
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.defaultRange)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            let confirmationAlert = UIAlertController(title: "Are you sure?", message: "This will delete all athletes that are not on your team. Sheets for these athletes will not be deleted.", preferredStyle: .alert)
            confirmationAlert.view.tintColor = AppColors.orange
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            cancelAction.setValue(AppColors.black, forKey: "titleTextColor")
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                Athlete.deleteAll(keepTeamMembers: true)
            })
            confirmationAlert.addAction(cancelAction)
            confirmationAlert.addAction(deleteAction)
            DispatchQueue.main.async {
                self.present(confirmationAlert, animated: true, completion: nil)
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.defaultRangeTextField.resignFirstResponder()
    }

}

extension SettingsTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.defaultRangeTextField.resignFirstResponder()
        return true
    }
    
}
