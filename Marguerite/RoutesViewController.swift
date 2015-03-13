//
//  RoutesViewController.swift
//  A UIViewController for viewing all of the routes in a table.
//
//  Created by Kevin Conley on 3/12/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit

class RoutesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Model

    private var routes = [Route]()

    // MARK: - Outlets

    @IBOutlet private weak var tableView: UITableView!

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get all routes, sorting them alphabetically (case-insensitive)
        routes = Route.getAllRoutes().sorted {
            $0.displayName.lowercaseString < $1.displayName.lowercaseString }
    }

    // MARK: - Storyboard Constants

    private struct Storyboard {
        static let routeTableViewCellIdentifier = "RouteTableCell"
        static let webViewControllerIdentifier = "WebViewController"
    }

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.routeTableViewCellIdentifier, forIndexPath: indexPath) as RouteTableViewCell
        let route = routes[indexPath.row]
        cell.route = route

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let wvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Storyboard.webViewControllerIdentifier) as WebViewController

        let route = routes[indexPath.row]
        wvc.urlToLoad = getURLForRoute(route)
        wvc.hideToolbar = true
        wvc.title = route.displayName

        let nc = UINavigationController(rootViewController: wvc)
        // Extend the layout below opaque bars since we're segueing from a
        // split view controller embedded in a tab bar controller, so this
        // will help avoid the autolayout glitches associated with that
        nc.extendedLayoutIncludesOpaqueBars = true
        showDetailViewController(nc, sender: self)
    }

    // MARK: - Route Maps

    /**
    Some of the routes have bogus URLs, so handle those cases with this function.

    :param: route The route.

    :returns: The URL for the map of the given route.
    */
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
