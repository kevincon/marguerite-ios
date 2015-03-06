//
//  NextShuttleTableViewController.swift
//  Marguerite
//
//  Created by Kevin Conley on 3/1/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit
import CoreLocation

class NextShuttleTableViewController: UITableViewController, CoreLocationControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, NextShuttleTableViewRefreshDelegate {

    let FEET_IN_MILES = 5280.0
    
    struct Storyboard {
        static let nearbyStopCellIdentifier = "NearbyStopCell"
        static let favoriteStopCellIdentifier = "FavoriteStopCell"
        static let allStopsCellIdentifier = "AllStopsCell"
        static let stopNavigationControllerIdentifier = "StopNavigationController"
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
    var searchResults = [Stop]()
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationController.delegate = self
        
        if favoriteStops.count > 0 {
            specialTableSections.addObject(favoriteStopsSection)
        }
        
        allStops = Stop.getAllStops()
        
        tableView.sectionIndexBackgroundColor = UIColor.groupTableViewBackgroundColor()
        tableView.sectionIndexTrackingBackgroundColor = UIColor.lightGrayColor()
        
        self.refreshControl?.addTarget(self, action: "refreshNearbyStops:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshNearbyStops(self)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // If we're searching, there's only one section
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return 1
        } else {
            // Our sections are (optionally) nearby stops, (optionally) favorite
            // stops, and then the number of "all stops" index sections
            return specialTableSections.count + allStopsSections.count
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If we're searching, use the search results
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return searchResults.count
        } else {
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
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // If we're searching, there shouldn't be a title
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return nil
        } else {
            if section < specialTableSections.count {
                let tableSection = specialTableSections[section] as TableSection
                return tableSection.header
            } else {
                let allStopsSectionIndex = section - specialTableSections.count
                return collation.sectionTitles[allStopsSectionIndex] as? String
            }
        }
        
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        // If we're searching, there shouldn't be any section index titles
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return nil
        } else {
            var specialSectionIndexTitles = [String]()
            specialSectionIndexTitles.append(UITableViewIndexSearch)
            for specialTableSection in specialTableSections.array as [TableSection] {
                specialSectionIndexTitles.append(specialTableSection.indexHeader!)
            }
            return specialSectionIndexTitles + (collation.sectionIndexTitles as [String])
        }
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        // Scrolling to top taken from http://stackoverflow.com/a/19093169
        if index == 0 {
            tableView.setContentOffset(CGPointMake(0.0, -tableView.contentInset.top), animated:false)
            return NSNotFound;
        }
        // Search icon isn't actually a section, but it still offsets 
        // everything, so we need to subtract one from the index
        return index - 1;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        let section = indexPath.section
        
        // If this is a search, only show search results (no nearby stops or favorites)
        if tableView == self.searchDisplayController!.searchResultsTableView {
            cell = self.tableView.dequeueReusableCellWithIdentifier(Storyboard.allStopsCellIdentifier) as UITableViewCell
            let stop = searchResults[indexPath.row]
            cell.textLabel?.text = stop.stopName
            return cell
        }
        
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
        
        // To get the navigation controller bar at the top, we will show a
        // navigation controller that already exists in the storyboard and is
        // already connected to a stop table view controller, so all we have
        // to do is access the first view controller in the navigation
        // controller's list of view controllers
        let nc: UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Storyboard.stopNavigationControllerIdentifier) as UINavigationController
        let stvc = nc.viewControllers.first as StopTableViewController

        var stop: Stop
        
        // If this is a search, look for the stop in the search results
        if tableView == self.searchDisplayController!.searchResultsTableView {
            stop = searchResults[indexPath.row]
        } else {
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
        }
        
        stvc.stop = stop
        stvc.refreshDelegate = self
        showDetailViewController(nc, sender: self)
    }
    
    // MARK: - Searching
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        filterStopsForSearchText(searchString)
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController, didHideSearchResultsTableView tableView: UITableView) {
        refreshFavoriteStops()
    }

    func filterStopsForSearchText(searchText: String) {
        let resultPredicate = NSPredicate(format: "stopName contains[cd] %@ OR stopId == %@", argumentArray: [searchText, searchText])
        searchResults = allStops.filter({ (stop: Stop) -> Bool in
            resultPredicate.evaluateWithObject(stop)
        })
    }
    
    // MARK: - GPS Location
    
    let locationController = CoreLocationController()
    
    func locationUpdate(location: CLLocation) {
        closestStops = Stop.getClosestStops(3, location: location)
        if closestStops.count > 0 {
            specialTableSections.insertObject(nearbyStopsSection, atIndex: 0)
        }
        if !self.searchDisplayController!.active {
            tableView.reloadData()
        }
        if self.refreshControl!.refreshing {
            self.refreshControl?.endRefreshing()
        }
    }
    
    func locationError(error: NSError) {
        // TODO better handling of location error
        print("GPS location error: \(error)")
    }
    
    func refreshNearbyStops(sender: AnyObject) {
        locationController.refreshLocation()
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
        
        if !self.searchDisplayController!.active {
            tableView.reloadData()
        }
    }
}
