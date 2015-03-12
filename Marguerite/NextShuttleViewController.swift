//
//  NextShuttleTableViewController.swift
//  Marguerite
//
//  Created by Kevin Conley on 3/1/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit
import CoreLocation

class NextShuttleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CoreLocationControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, NextShuttleTableViewRefreshDelegate {

    @IBOutlet weak var tableView: UITableView!
    var refreshControl = UIRefreshControl()
    
    let FEET_IN_MILES = 5280.0
    
    struct Storyboard {
        static let nearbyStopCellIdentifier = "NearbyStopCell"
        static let favoriteStopCellIdentifier = "FavoriteStopCell"
        static let allStopsCellIdentifier = "AllStopsCell"
        static let stopViewControllerIdentifier = "StopViewController"
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

        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh nearby stops.")
        refreshControl.addTarget(self, action: "refreshNearbyStops:", forControlEvents: UIControlEvents.ValueChanged)

        allStops = Stop.getAllStops()
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshNearbyStops(self)
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // If we're searching, there's only one section
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return 1
        } else {
            // Our sections are (optionally) nearby stops, (optionally) favorite
            // stops, and then the number of "all stops" index sections
            return specialTableSections.count + allStopsSections.count
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        // If we're searching, there shouldn't be any section index titles
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return nil
        } else {
            var specialSectionIndexTitles = [String]()
            for specialTableSection in specialTableSections.array as [TableSection] {
                specialSectionIndexTitles.append(specialTableSection.indexHeader!)
            }
            return specialSectionIndexTitles + (collation.sectionIndexTitles as [String])
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
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
                
                let distanceInFeet = Int(stop.milesAway! * self.FEET_IN_MILES)
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

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let svc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Storyboard.stopViewControllerIdentifier) as StopViewController
    
        var stop: Stop?
            
        if searchDisplayController!.active {
            if let indexPath = searchDisplayController?.searchResultsTableView.indexPathForSelectedRow() {
                
                // If this is a search, look for the stop in the search results
                stop = searchResults[indexPath.row]
            }
        } else if let indexPath = tableView.indexPathForSelectedRow() {
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
        
        if let s = stop {
            svc.stop = stop
            svc.refreshDelegate = self
            
            let nc = UINavigationController(rootViewController: svc)
            
            // This is crucial so that a gray bar does not appear at the bottom
            nc.extendedLayoutIncludesOpaqueBars = true
            
            showDetailViewController(nc, sender: self)

        }
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

    func locationAuthorizationStatusChanged(nowEnabled: Bool) {
        if nowEnabled {
            locationController.refreshLocation()
        } else {
            // Remove the refresh control and nearby stops section since
            // location is now disabled
            if refreshControl.superview != nil {
                if refreshControl.refreshing {
                    refreshControl.endRefreshing()
                }
                refreshControl.removeFromSuperview()
            }
        }
    }

    func locationUpdate(location: CLLocation) {
        closestStops = Stop.getClosestStops(3, location: location)
        if closestStops.count > 0 {
            specialTableSections.insertObject(nearbyStopsSection, atIndex: 0)

            if refreshControl.superview == nil {
                tableView.addSubview(refreshControl)
            }
        }
        if !self.searchDisplayController!.active {
            tableView.reloadData()
        }
        if refreshControl.refreshing {
            refreshControl.endRefreshing()
        }
    }
    
    func locationError(error: NSError) {
        // TODO better handling of location error
        println("GPS location error: \(error)")

        if refreshControl.refreshing {
            refreshControl.endRefreshing()
        }
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
