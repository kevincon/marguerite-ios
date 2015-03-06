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
    
    let nearbyStopsSection = TableSection(header: "Nearby Stops", indexHeader: "◎")
    let favoriteStopsSection = TableSection(header: "Favorite Stops", indexHeader: "♥︎")
    
    // MARK: - Data
    
    var specialTableSections = NSMutableOrderedSet()
    
    let collation = UILocalizedIndexedCollation.currentCollation() as UILocalizedIndexedCollation
    
    var closestStops = [Stop]()
    var favoriteStops = Stop.favoriteStops
    var allStopsSections: [[Stop]] = []
    var allStops: [Stop] = [] {
        didSet {
            let selector: Selector = "stopName"
            allStopsSections = [[Stop]](count: collation.sectionTitles.count, repeatedValue: [])
            
            let sortedStops = collation.sortedArrayFromArray(allStops, collationStringSelector: selector) as [Stop]
            for stop in sortedStops {
                let sectionNumber = collation.sectionForObject(stop, collationStringSelector: selector)
                allStopsSections[sectionNumber].append(stop)
            }
        }
    }
    //var searchResults = [Stop]()
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationController.delegate = self
        
        if favoriteStops.count > 0 {
            specialTableSections.addObject(favoriteStopsSection)
        }
        
        allStops = Stop.getAllStops()
        
        tableView.sectionIndexBackgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
        tableView.sectionIndexTrackingBackgroundColor = UIColor.lightGrayColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        locationController.refreshLocation()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Our sections are (optionally) nearby stops, (optionally) favorite
        // stops, and then the number of "all stops" index sections
        return specialTableSections.count + allStopsSections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < specialTableSections.count {
            switch specialTableSections[section] as TableSection {
            case nearbyStopsSection:
                return closestStops.count
            case favoriteStopsSection:
                return favoriteStops.count
            default:
                return 0
            }
        } else {
            let allStopsSectionIndex = section - specialTableSections.count
            return allStopsSections[allStopsSectionIndex].count
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < specialTableSections.count {
            let tableSection = specialTableSections[section] as TableSection
            return tableSection.header
        } else {
            let allStopsSectionIndex = section - specialTableSections.count
            return collation.sectionTitles[allStopsSectionIndex] as? String
        }
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        var specialSectionIndexTitles = [String]()
        for specialTableSection in specialTableSections.array as [TableSection] {
            specialSectionIndexTitles.append(specialTableSection.indexHeader!)
        }
        return specialSectionIndexTitles + (collation.sectionIndexTitles as [String])
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        let section = indexPath.section
        if section < specialTableSections.count {
            switch specialTableSections[section] as TableSection {
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
            default:
                break
            }
        } else {
            let allStopsSectionIndex = section - specialTableSections.count
            let stop = allStopsSections[allStopsSectionIndex][indexPath.row]
            cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.allStopsCellIdentifier, forIndexPath: indexPath) as UITableViewCell
            
            cell.textLabel?.text = stop.stopName
        }
    
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        let stvc: StopTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StopTableViewController") as StopTableViewController

        var stop: Stop
        
        let section = indexPath.section
        if section < specialTableSections.count {
            switch specialTableSections[section] as TableSection {
            case nearbyStopsSection:
                stop = closestStops[indexPath.row]
            case favoriteStopsSection:
                stop = favoriteStops[indexPath.row]
            default:
                return
            }
        } else {
            let allStopsSectionIndex = section - specialTableSections.count
            stop = allStopsSections[allStopsSectionIndex][indexPath.row]
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
            specialTableSections.insertObject(nearbyStopsSection, atIndex: 0)
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
            specialTableSections.removeObject(favoriteStopsSection)
        } else {
            specialTableSections.addObject(favoriteStopsSection)
        }
        
        tableView.reloadData()
    }
}
