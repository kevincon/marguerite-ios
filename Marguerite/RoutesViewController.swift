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

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let wvc = segue.destinationViewController as? WebViewController {
            if let indexPath = tableView.indexPathForSelectedRow() {
                let route = routes[indexPath.row]
                wvc.urlToLoad = getURLForRoute(route)
                wvc.hideToolbar = true
            }
        }
    }

    // MARK: - Route Maps

    // Some of the routes have bogus URLs, so handle those cases with this function
    private func getURLForRoute(route: Route) -> NSURL? {
        switch route.routeShortName {
        case "RMH":
            // This route doesn't actually seem to exist on the Marguerite website...
            return nil
        case "W":
            return NSURL(string: "http://transportation.stanford.edu/marguerite/w/map.pdf")
        case "MC-Hol":
            return NSURL(string: "http://transportation.stanford.edu/marguerite/mch/map.pdf")
        default:
            return NSURL(string: "\(route.routeUrl.absoluteString!)/map.pdf")
        }
    }
}
