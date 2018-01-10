//
//  UITextViewExtensions.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/9/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit


/// Custom class to remove content padding in a `UITextView`.
/// When using this class, make sure to disable scrolling in Interface Builder.
@IBDesignable class UITextViewFixed: UITextView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setup()
    }
    
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
    
}
