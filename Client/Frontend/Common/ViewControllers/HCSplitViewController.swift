//
//  HCSplitViewController.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class HCSplitViewController: UISplitViewController {

    /// Whether to collapse the secondary view controller onto the master view controller.
    var collapseSecondaryViewController = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Always show the master view controller.
        self.preferredDisplayMode = .allVisible
        self.presentsWithGesture = false
        self.delegate = self
    }
    
    /// Pop all view controllers off the bottom-most `UINavigationController`'s stack.
    func popToRootViewController(animated: Bool) {
        if let navigationController = self.viewControllers.first(where: { $0 is UINavigationController }) as? UINavigationController {
            DispatchQueue.main.async {
                navigationController.popToRootViewController(animated: animated)
            }
        }
    }
    
    /// Pop the top view controller off the top-most `UINavigationController`'s stack.
    func popViewController(animated: Bool) {
        if let index = self.viewControllers.indexOfLast(where: { $0 is UINavigationController }),
            let navigationController = self.viewControllers[index] as? UINavigationController {
            DispatchQueue.main.async {
                navigationController.popViewController(animated: animated)
            }
        }
    }
    
}

extension HCSplitViewController: UISplitViewControllerDelegate {

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return self.collapseSecondaryViewController
    }
    
}
