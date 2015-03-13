//
//  RouteTableViewCell.swift
//  A UITableViewCell for viewing a route.
//
//  Created by Kevin Conley on 3/13/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit

class RouteTableViewCell: UITableViewCell {

    // MARK: - Public API

    var route: Route? {
        didSet {
            routeLabel?.text = " \(route!.displayName) "
            routeLabel?.textAlignment = .Left
            routeLabel?.textColor = route!.routeTextColor
            routeLabel?.backgroundColor = route!.routeColor
            routeLabel?.sizeToFit()
            routeLabel?.layer.cornerRadius = 4
            routeLabel?.layer.masksToBounds = true
        }
    }

    // MARK: - Outlets

    @IBOutlet private weak var routeLabel: UILabel!
}
