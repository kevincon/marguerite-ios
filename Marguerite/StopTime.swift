//
//  StopTime.swift
//  A GTFS stop time.
//
//  Created by Kevin Conley on 3/4/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit

class StopTime: NSObject {
    var departureTime: NSDate?
    var routeLongName: String?
    var routeShortName: String?
    var routeColor: UIColor?
    var routeTextColor: UIColor?
    var tripId: String?

    /// The text to display for a route (some routes are missing the long name
    /// field or short name field)
    var displayName: String {
        if self.routeLongName!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != "" {
            return self.routeLongName!
        } else {
            return self.routeShortName!
        }
    }
}
