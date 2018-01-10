//
//  SelectableTableViewCell.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/5/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class SelectableTableViewCell: UITableViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var selectionIndicator: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.selectionIndicator.image = #imageLiteral(resourceName: "CheckmarkSelected")
            self.selectionIndicator.tintColor = AppColors.orange
        } else {
            self.selectionIndicator.image = #imageLiteral(resourceName: "Checkmark")
            self.selectionIndicator.tintColor = AppColors.darkGray
        }
    }
    
    func configure(with text: String) {
        self.infoLabel.text = text
    }

}
