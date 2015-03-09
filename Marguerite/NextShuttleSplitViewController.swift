//
//  NextShuttleSplitViewController.swift
//  Marguerite
//
//  Created by Kevin Conley on 3/2/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit

class NextShuttleSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        self.delegate = self
    }
    
    // https://stackoverflow.com/questions/25875618/uisplitviewcontroller-in-portrait-on-iphone-shows-detail-vc-instead-of-master
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
        return true
    }
}
