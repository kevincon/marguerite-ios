//
//  RealtimeBus.swift
//  A real-time Marguerite shuttle bus.
//
//  Created by Kevin Conley on 3/8/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit
import CoreLocation

class RealtimeBus: NSObject {
    var route: Route
    var vehicleId: String
    var location: CLLocationCoordinate2D
    var heading: Double = 0
    var dictionary = [String: String]()

    class func initWithRouteId(routeId: String, andVehicleId vehicleId: String, andLocation location: CLLocationCoordinate2D) -> RealtimeBus? {
        if let route = Route(routeId: routeId) {
            return RealtimeBus(route: route, vehicleId: vehicleId, location: location)
        } else {
            return nil
        }
    }
    
    init(route: Route, vehicleId: String, location: CLLocationCoordinate2D) {
        self.vehicleId = vehicleId
        self.location = location
        self.route = route
    }
}
