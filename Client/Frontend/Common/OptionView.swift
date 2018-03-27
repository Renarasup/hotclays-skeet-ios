//
//  OptionView.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 3/27/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class OptionView: UIView {

    func configure(with option: Option, selected: Bool) {
        // Set background for given option
        switch option.shot {
        case .hit:
            self.backgroundColor = AppColors.orange
        case .miss:
            self.backgroundColor = AppColors.darkGray
        case .notTaken:
            self.backgroundColor = AppColors.lightGray
        }
        
        // TODO: Draw hit/miss indicator
        
        // TODO: Indicate where the option was taken
        
        // Set border for selected state
        if selected {
            self.layer.borderColor = AppColors.black.cgColor
            self.layer.borderWidth = CommonConstants.scoreCellSelectedBorderWidth
        } else {
            self.layer.borderWidth = 0.0
        }
    }

}
