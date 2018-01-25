//
//  EditSheetTableViewController.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class EditSheetTableViewController: UITableViewController {

    @IBOutlet weak var eventTextField: UITextField!
    @IBOutlet weak var rangeTextField: UITextField!
    @IBOutlet weak var fieldTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var notesTextView: UITextView!
    
    var delegate: EditSheetDelegate!
    private var isCreatingNewSheet = true
    
    @IBAction func pressedCancelButton(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func pressedDoneButton(_ sender: UIBarButtonItem) {
        // Validate all input fields. Present alerts if anything is invalid.
        guard let event = self.eventTextField.text, event.count > 0 else {
            self.presentAlert(title: "Invalid Event", message: "Please specify a non-empty event.")
            return
        }
        guard let range = self.rangeTextField.text, range.count > 0 else {
            self.presentAlert(title: "Invalid Range", message: "Please specify a non-empty range.")
            return
        }
        guard let fieldString = self.fieldTextField.text else {
            // Should never hit this.
            self.presentAlert(title: "Invalid Field Number", message: "Please specify a non-empty field number.")
            return
        }
        guard let notesString = self.notesTextView.text, notesString.count <= Sheet.maxLengthOfNotes else {
            self.presentAlert(title: "Too Many Notes", message: "Please limit your notes to 300 characters.")
            return
        }
        if fieldString.count > 0 {
            let fieldInt = Int(fieldString)
            if fieldInt == nil || fieldInt! <= 0 || fieldInt! > Sheet.maxFieldNumber {
                self.presentAlert(title: "Invalid Field Number", message: "Please specify a field number between 1 and \(Sheet.maxFieldNumber).")
                return
            }
        }
        
        let date = self.datePicker.date
        let field = fieldString.count > 0 ? fieldString : nil
        let notes = notesString.count > 0 ? notesString : nil
        
        self.commitEdits(date: date, event: event, range: range, field: field, notes: notes)
    }

    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        self.dateTextField.text = DateFormatter.localizedString(from: sender.date, dateStyle: .medium, timeStyle: .short)
        self.hideKeyboard()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate existing sheet info.
        if let date = delegate.date {
            self.datePicker.setDate(date, animated: false)
            self.dateTextField.text = DateFormatter.localizedString(from: self.datePicker.date, dateStyle: .medium, timeStyle: .short)
            self.isCreatingNewSheet = false
        }
        if let event = delegate.event {
            self.eventTextField.text = event
            self.isCreatingNewSheet = false
        }
        if let range = delegate.range {
            self.rangeTextField.text = range
            self.isCreatingNewSheet = false
        } else if let defaultRange = UserDefaults.standard.string(forKey: UserDefaultsKeys.defaultRange) {
            self.rangeTextField.text = defaultRange
        }
        if let field = delegate.field {
            self.fieldTextField.text = "\(field)"
            self.isCreatingNewSheet = false
        }
        if let notes = delegate.notes {
            self.notesTextView.text = notes
            self.isCreatingNewSheet = false
        }
        self.datePicker.isHidden = true
        self.navigationItem.title = self.isCreatingNewSheet ? "New Sheet" : "Edit Sheet"
    }

    override func viewDidAppear(_ animated: Bool) {
        self.eventTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.hideKeyboard()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 && indexPath.row == 0 {
            self.hideKeyboard()
            self.setDatePickerHidden(isHidden: !self.datePicker.isHidden)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 && indexPath.row == 1 {
            return self.datePicker.isHidden ? 0.0 : ScoreConstants.addEventDatePickerTableViewCellHeight
        } else if indexPath.section == 4 {
            return ScoreConstants.addEventNotesTableViewCellHeight
        } else {
            return ScoreConstants.addSheetTableViewCellHeight
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.hideKeyboard(includingNotesTextView: false)
    }
    
    private func commitEdits(date: Date, event: String, range: String, field: String?, notes: String?) {
        // Pass sheet info to delegate and dismiss view controller.
        self.delegate.didAdd(date: date, event: event, range: range, field: field, notes: notes)
        DispatchQueue.main.async {
            self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func hideKeyboard(includingNotesTextView: Bool = true) {
        self.eventTextField.resignFirstResponder()
        self.rangeTextField.resignFirstResponder()
        self.fieldTextField.resignFirstResponder()
        if includingNotesTextView {
            self.notesTextView.resignFirstResponder()
        }
    }
    
    private func setDatePickerHidden(isHidden: Bool) {
        guard self.datePicker.isHidden != isHidden else {
            return
        }
        let indexPathOfDateRow = IndexPath(row: 0, section: 3)
        self.datePicker.isHidden = isHidden
        if self.dateTextField.text?.count ?? 0 == 0 {
            self.dateTextField.text = DateFormatter.localizedString(from: self.datePicker.date, dateStyle: .medium, timeStyle: .short)
        }
        self.dateTextField.textColor = isHidden ? AppColors.black : AppColors.orange
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.tableView.beginUpdates()
                        self.tableView.deselectRow(at: indexPathOfDateRow, animated: true)
                        self.tableView.endUpdates()
        })
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

}

extension EditSheetTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.eventTextField {
            self.rangeTextField.becomeFirstResponder()
        } else if textField == self.rangeTextField {
            self.fieldTextField.becomeFirstResponder()
        } else if textField == self.fieldTextField {
            self.fieldTextField.resignFirstResponder()
            self.setDatePickerHidden(isHidden: false)
        }
        return true
    }
    
}
