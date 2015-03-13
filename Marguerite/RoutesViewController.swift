//
//  RoutesViewController.swift
//  Marguerite
//
//  Created by Kevin Conley on 3/12/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit

class RoutesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Model

    var routes = [Route]()

    // MARK: - Outlets

    @IBOutlet weak var tableView: UITableView!

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        routes = Route.getAllRoutes()
    }

    // MARK: - Storyboard Constants

    private struct Storyboard {
        static let routeTableViewCellIdentifier = "RouteTableCell"
    }

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.routeTableViewCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        let route = routes[indexPath.row]
        if route.routeLongName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != "" {
            cell.textLabel?.text = route.routeLongName
        } else {
            cell.textLabel?.text = route.routeShortName
        }
        cell.textLabel?.textColor = route.routeTextColor
        cell.backgroundColor = route.routeColor

        return cell
    }
}
