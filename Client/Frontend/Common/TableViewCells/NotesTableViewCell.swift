//
//  NotesTableViewCell.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/9/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class NotesTableViewCell: UITableViewCell {

    @IBOutlet weak var notesTextView: UITextViewFixed!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with notes: String?) {
        if let notes = notes {
            self.notesTextView.text = notes
            self.notesTextView.textColor = AppColors.black
        } else {
            self.notesTextView.text = ""
            self.notesTextView.textColor = AppColors.darkGray
        }
    }

}
