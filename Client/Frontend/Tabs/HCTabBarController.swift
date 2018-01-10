//
//  HCTabBarController.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/8/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class HCTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

}

extension HCTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Second tap on tab pops to root view controller.
        if viewController == tabBarController.selectedViewController,
            let splitViewController = viewController as? HCSplitViewController {
            splitViewController.popToRootViewController(animated: true)
        }
        return true
    }
    
}
