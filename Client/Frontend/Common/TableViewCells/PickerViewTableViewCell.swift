//
//  PickerViewTableViewCell.swift
//  HotClays Trap
//
//  Created by Christopher Chute on 1/5/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class PickerViewTableViewCell: UITableViewCell {

    @IBOutlet weak var pickerView: UIPickerView!
    
    override func awakeFromNib() {
        self.pickerView.selectRow(0, inComponent: 0, animated: false)
    }
    
    func setPickerViewHidden(_ isHidden: Bool) {
        self.pickerView.isHidden = isHidden
    }

}
