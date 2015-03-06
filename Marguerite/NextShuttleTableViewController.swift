//
//  NextShuttleTableViewController.swift
//  Marguerite
//
//  Created by Kevin Conley on 3/1/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit
import CoreLocation

class NextShuttleTableViewController: UITableViewController, CoreLocationControllerDelegate, NextShuttleTableViewRefreshDelegate {

    let FEET_IN_MILES = 5280.0
    
    struct Storyboard {
        static let nearbyStopCellIdentifier = "NearbyStopCell"
        static let favoriteStopCellIdentifier = "FavoriteStopCell"
        static let allStopsCellIdentifier = "AllStopsCell"
    }
    
    let nearbyStopsSection = TableSection(header: "Nearby Stops")
    let favoriteStopsSection = TableSection(header: "Favorite Stops")
    let allStopsSection = TableSection(header: "All Stops")
    
    // MARK: - Data
    
    var tableSections = NSMutableOrderedSet()
    
    var closestStops = [Stop]()
    var favoriteStops = Stop.favoriteStops
    var allStops: [Stop] = Stop.getAllStops().sorted { (firstStop, secondStop) -> Bool in
        firstStop.stopName < secondStop.stopName
    }
    //var searchResults = [Stop]()
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationController.delegate = self
        
        if favoriteStops.count > 0 {
            tableSections.addObject(favoriteStopsSection)
        }
        
        tableSections.addObject(allStopsSection)
    }
    
    override func viewWillAppear(animated: Bool) {
        locationController.refreshLocation()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableSections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableSections[section] as TableSection {
            case nearbyStopsSection:
                return closestStops.count
            case favoriteStopsSection:
                return favoriteStops.count
            case allStopsSection:
                return allStops.count
            default:
                return 0
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let tableSection = tableSections[section] as TableSection
        return tableSection.header
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        switch tableSections[indexPath.section] as TableSection {
        case nearbyStopsSection:
            cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.nearbyStopCellIdentifier, forIndexPath: indexPath) as UITableViewCell
            let stop = closestStops[indexPath.row]
            cell.textLabel?.text = stop.stopName
            
            let distanceInFeet = stop.milesAway! * self.FEET_IN_MILES
            var distanceString: String
            if (stop.milesAway < 1.0) {
                distanceString = String(format: "%d feet", distanceInFeet)
            } else {
                distanceString = String(format: "%.2f miles", stop.milesAway!)
            }
            
            cell.detailTextLabel?.text = distanceString
        case favoriteStopsSection:
            cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.favoriteStopCellIdentifier, forIndexPath: indexPath) as UITableViewCell
            let stop = favoriteStops[indexPath.row]
            cell.textLabel?.text = stop.stopName
        case allStopsSection:
            cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.allStopsCellIdentifier, forIndexPath: indexPath) as UITableViewCell
            let stop = allStops[indexPath.row]
            cell.textLabel?.text = stop.stopName
        default:
            break
        }
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        let stvc: StopTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StopTableViewController") as StopTableViewController

        var stop: Stop
        
        switch tableSections[indexPath.section] as TableSection {
        case nearbyStopsSection:
            stop = closestStops[indexPath.row]
        case favoriteStopsSection:
            stop = favoriteStops[indexPath.row]
        case allStopsSection:
            stop = allStops[indexPath.row]
        default:
            return
        }
        
        stvc.stop = stop
        stvc.refreshDelegate = self
        showDetailViewController(stvc, sender: self)
        
    }
    
    // MARK: - GPS Location
    
    let locationController = CoreLocationController()
    
    func locationUpdate(location: CLLocation) {
        closestStops = Stop.getClosestStops(3, location: location)
        if closestStops.count > 0 {
            tableSections.insertObject(nearbyStopsSection, atIndex: 0)
        }
        tableView.reloadData()
    }
    
    func locationError(error: NSError) {
        // TODO better handling of location error
        print("GPS location error: \(error)")
    }
    
    // MARK: - Refresh delegate
    
    func refreshFavoriteStops() {
        favoriteStops = Stop.favoriteStops
        // Remove or add the Favorite Stops table section based on whether or
        // not there are any favorite stops and if Nearby Stops is being shown
        if favoriteStops.count == 0 {
            tableSections.removeObject(favoriteStopsSection)
        } else if tableSections.count == 1 {
            tableSections.insertObject(favoriteStopsSection, atIndex: 0)
        } else if tableSections.count == 2 {
            tableSections.insertObject(favoriteStopsSection, atIndex: 1)
        }
        tableView.reloadData()
    }
}
