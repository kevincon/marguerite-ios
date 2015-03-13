//
//  Route.swift
//  A GTFS route.
//
//  Created by Kevin Conley on 3/8/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit

class Route {
    var routeId: String
    var routeShortName: String
    var routeLongName: String
    var routeUrl: NSURL
    var routeColor = UIColor()
    var routeTextColor = UIColor()

    /// The text to display for a route (some routes are missing the long name
    /// field or short name field)
    var displayName: String {
        if self.routeLongName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != "" {
            return self.routeLongName
        } else {
            return self.routeShortName
        }
    }

    // MARK: - Initializers

    init?(routeId: String) {
        self.routeId = ""
        self.routeShortName = ""
        self.routeLongName = ""
        self.routeUrl = NSURL()
        
        if let db = GTFSDatabase.open() {
            let routesQuery = "SELECT route_long_name, route_short_name, route_url, route_color, route_text_color FROM routes WHERE route_id=?"
            let routesRS = db.executeQuery(routesQuery, withArgumentsInArray: [routeId])
            if routesRS.next() {
                self.routeId = routeId
                self.routeLongName = routesRS.objectForColumnName("route_long_name") as String
                self.routeShortName = routesRS.objectForColumnName("route_short_name") as String
                self.routeUrl = NSURL(string: routesRS.objectForColumnName("route_url") as String)!
                self.routeColor = UIColor.colorFromHexString(routesRS.objectForColumnName("route_color") as String)
                self.routeTextColor = UIColor.colorFromHexString(routesRS.objectForColumnName("route_text_color") as String)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    init(routeId: String, routeShortName: String, routeLongName: String, routeUrl: NSURL, routeColor: UIColor, routeTextColor: UIColor) {
        self.routeId = routeId
        self.routeShortName = routeShortName
        self.routeLongName = routeLongName
        self.routeUrl = routeUrl
        self.routeColor = routeColor
        self.routeTextColor = routeTextColor
    }

    // MARK: - Class Functions

    /**
    Get a list of all routes from the GTFS data.

    :returns: All of the routes from the GTFS.
    */
    class func getAllRoutes() -> [Route] {
        var allRoutes = [Route]()
        if let db = GTFSDatabase.open() {
            let allRoutesQuery = "select route_id FROM routes"
            let resultSet = db.executeQuery(allRoutesQuery, withArgumentsInArray: [])

            while resultSet.next() {
                if let routeId = resultSet.objectForColumnName("route_id") as? String {
                    if let route = Route(routeId: routeId) {
                        allRoutes.append(route)
                    }
                }
            }
            resultSet.close()
            db.close()
        }
        return allRoutes
    }
}
