//
//  CGSizeExtensions.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

extension CGSize {
    
    /// Create a `CGSize` with equal height and width.
    ///
    /// - Parameter sideLength: Length for height and width.
    init(square sideLength: CGFloat) {
        self.init(width: sideLength, height: sideLength)
    }
    
}
