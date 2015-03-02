//
//  NextShuttleTableViewController.swift
//  Marguerite
//
//  Created by Kevin Conley on 3/1/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit

class NextShuttleTableViewController: UITableViewController {

    let FEET_IN_MILES = 5280
    
    struct Storyboard {
        static let nearbyStopCellIdentifier = "NearbyStopCell"
        static let favoriteStopCellIdentifier = "FavoriteStopCell"
        static let allStopsCellIdentifier = "AllStopsCell"
    }
    
    struct TableSections {
        static let nearbyStopsSectionIndex = 0
        static let nearbyStopsSectionHeader = "Nearby Stops"
        
        static let favoriteStopsSectionIndex = 1
        static let favoriteStopsSectionHeader = "Favorite Stops"
        
        static let allStopsSectionIndex = 2
        static let allStopsSectionHeader = "All Stops"
        
        static let numberOfSections = 3
    }
    
    // MARK: - API
    
    //var closestStops: [Stop]
    var favoriteStops = [Stop]()
    var allStops: [Stop] = Stop.getAllStops().sorted { (firstStop, secondStop) -> Bool in
        firstStop.stopName < secondStop.stopName
    }
    //var searchResults = [Stop]()
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let fStops = Stop.getFavoriteStops() {
            favoriteStops.extend(fStops)
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSections.numberOfSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            //case TableSections.nearbyStopsSectionIndex:
            //    return TableSections.nearbyStopsSectionHeader
            case TableSections.favoriteStopsSectionIndex:
                return favoriteStops.count
            case TableSections.allStopsSectionIndex:
                return allStops.count
            default:
                return 0
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case TableSections.nearbyStopsSectionIndex:
                return TableSections.nearbyStopsSectionHeader
            case TableSections.favoriteStopsSectionIndex:
                return TableSections.favoriteStopsSectionHeader
            case TableSections.allStopsSectionIndex:
                return TableSections.allStopsSectionHeader
            default:
                return nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        switch indexPath.section {
        case TableSections.favoriteStopsSectionIndex:
            cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.favoriteStopCellIdentifier, forIndexPath: indexPath) as UITableViewCell
            let stop = favoriteStops[indexPath.row]
            cell.textLabel?.text = stop.stopName
        case TableSections.allStopsSectionIndex:
            cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.allStopsCellIdentifier, forIndexPath: indexPath) as UITableViewCell
            let stop = allStops[indexPath.row]
            cell.textLabel?.text = stop.stopName
        default:
            break
        }
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
