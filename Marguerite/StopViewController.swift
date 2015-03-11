//
//  StopViewControllerTableViewController.swift
//  Marguerite
//
//  Created by Kevin Conley on 3/4/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit

protocol NextShuttleTableViewRefreshDelegate: class {
    func refreshFavoriteStops()
}

class StopViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var refreshDelegate: NextShuttleTableViewRefreshDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableSections.append(toggleFavoriteStopSection)
        tableSections.append(viewOnMapSection)
        tableSections.append(busesSection)
    }

    // MARK: - Querying next shuttles
    
    func getNextBuses() -> [StopTime] {
        if let db = GTFSDatabase.open() {
            let currentDate = NSDate()
            
            // Create a yyyy-MM-dd date string for today's date
            let dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "yyyy-MM-dd"
            let todaysDate = dateFormat.stringFromDate(currentDate)
            
            // Create a HH:mm:ss time string for the current time
            let timeFormat = NSDateFormatter()
            timeFormat.dateFormat = "HH:mm:ss"
            let timeString = timeFormat.stringFromDate(currentDate)
            
            if let routesString = stop?.routesString {
                if let stopId = stop?.stopId {
                    let departureTimesQuery = String(format: "SELECT stop_times.departure_time, routes.route_long_name, routes.route_color, routes.route_text_color, trips.trip_id FROM routes, trips, calendar_dates, stop_times WHERE trips.service_id=calendar_dates.service_id AND calendar_dates.date=? AND stop_times.pickup_type=0 AND stop_times.trip_id=trips.trip_id AND routes.route_id=trips.route_id AND stop_times.stop_id=? AND trips.route_id IN (%@) AND time(stop_times.departure_time) > time(\'%@\') GROUP BY stop_times.departure_time, routes.route_long_name ORDER BY time(stop_times.departure_time)", arguments: [routesString, timeString])
                    
                    let departureTimesRS = db.executeQuery(departureTimesQuery, withArgumentsInArray: [todaysDate, stopId])
                    
                    var todaysBuses = [StopTime]()
                    let calendar = NSCalendar.currentCalendar()
                    while departureTimesRS.next() {
                        let bus = StopTime()
                        bus.routeLongName = departureTimesRS.objectForColumnName("route_long_name") as? String
                        bus.tripId = departureTimesRS.objectForColumnName("trip_id") as? String
                        bus.routeColor = UIColor.colorFromHexString(departureTimesRS.objectForColumnName("route_color") as String)
                        bus.routeTextColor = UIColor.colorFromHexString(departureTimesRS.objectForColumnName("route_text_color") as String)
                        var departureTime = departureTimesRS.objectForColumnName("departure_time") as String
                        
                        // Some departure times have 24 as the hour, so we need to change that to 00
                        var timeTokens = departureTime.componentsSeparatedByString(":")
                        if timeTokens[0] == "24" {
                            timeTokens[0] = "00"
                            departureTime = ":".join(timeTokens)
                        }
                        
                        bus.departureTime = timeFormat.dateFromString(departureTime)
                        
                        let components = calendar.components(NSCalendarUnit.CalendarUnitHour, fromDate: bus.departureTime!)
                        let hour = components.hour
                        if hour == 24 {
                            bus.departureTime = bus.departureTime?.dateByAddingTimeInterval(86400)
                        }
                        
                        todaysBuses.append(bus)
                    }
                    
                    departureTimesRS.close()
                    db.close()
                    return todaysBuses
                }
            }
        }

        return []
    }
    
    // MARK: - Model
    
    struct Storyboard {
        static let toggleFavoriteStopCellIdentifier = "ToggleFavoriteStopCell"
        static let viewOnMapCellIdentifier = "ViewOnMapCell"
        static let busCellIdentifier = "BusCell"
    }
    
    let toggleFavoriteStopSection = TableSection()
    let viewOnMapSection = TableSection()
    let busesSection = TableSection(header: "Next Shuttles", indexHeader: nil)

    var tableSections = [TableSection]()
    
    var stop: Stop? {
        didSet {
            if stop != nil {
                self.title = stop!.stopName
                isFavoriteStop = stop!.isFavoriteStop
                nextBuses = getNextBuses()
            }
        }
    }
    var isFavoriteStop: Bool = false {
        didSet {
            if isFavoriteStop {
                toggleFavoriteStopText = "Remove Favorite Stop"
            } else {
                toggleFavoriteStopText = "Add Favorite Stop"
            }
        }
    }
    
    var toggleFavoriteStopText = "Add Favorite Stop"
    
    var nextBuses = [StopTime]()
    
    // MARK: - Toggling favorite stop
    
    func addStopToFavorites() {
        var favoriteStops = Stop.favoriteStops
        favoriteStops.append(stop!)
        Stop.favoriteStops = favoriteStops
        isFavoriteStop = true
        tableView.reloadData()
        refreshDelegate?.refreshFavoriteStops()
    }
        
    func removeStopFromFavorites() {
        let newFavoriteStops = Stop.favoriteStops.filter({(stop: Stop) -> Bool in
            return stop.stopId != self.stop?.stopId
        })
        Stop.favoriteStops = newFavoriteStops
        isFavoriteStop = false
        tableView.reloadData()
        refreshDelegate?.refreshFavoriteStops()
    }
    
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableSections.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableSections[section] {
        case toggleFavoriteStopSection:
            return 1
        case viewOnMapSection:
            return 1
        case busesSection:
            return nextBuses.count
        default:
            return 0
        }
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let tableSection = tableSections[section]
        return tableSection.header
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch tableSections[section] {
        case busesSection:
            if nextBuses.count == 0 {
                return "Today's service complete."
            }
        default:
            break
        }
        
        return nil
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        switch tableSections[indexPath.section] {
        case toggleFavoriteStopSection:
            cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.toggleFavoriteStopCellIdentifier, forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = toggleFavoriteStopText
        case viewOnMapSection:
            cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.viewOnMapCellIdentifier, forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = "View on Map"
        case busesSection:
            cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.busCellIdentifier, forIndexPath: indexPath) as UITableViewCell
            let busCell = cell as StopTimeTableViewCell
            
            let twelveHourFormat = NSDateFormatter()
            twelveHourFormat.dateFormat = "h:mm a"
            
            let stopTime = nextBuses[indexPath.row]
            
            busCell.departureTimeLabel?.text = twelveHourFormat.stringFromDate(stopTime.departureTime!)
            busCell.routeLabel?.text = stopTime.routeLongName
            busCell.routeLabel?.textColor = stopTime.routeColor
        default:
            break
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch tableSections[indexPath.section] {
        case toggleFavoriteStopSection:
            if isFavoriteStop {
                removeStopFromFavorites()
            } else {
                addStopToFavorites()
            }
            tableView.cellForRowAtIndexPath(indexPath)!.selected = false
        default:
            break
        }
    }
}
