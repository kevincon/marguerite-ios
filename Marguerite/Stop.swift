//
//  Stop.swift
//  Marguerite
//
//  Created by Kevin Conley on 3/1/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit
import CoreLocation

class Stop: NSObject, NSCoding {
    
    struct Conversions {
        static let METERS_IN_A_MILE = 0.000621371
    }
    
    struct UserDefaults {
        static let favoriteStopsKey = "favoriteStops"
    }
    
    struct NSCodingKeys {
        static let stopIdKey = "stopId"
    }
    
    // MARK: - Static Functions
    
    class var favoriteStops: [Stop] {
        get {
            if let data = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaults.favoriteStopsKey) as? NSData {
                return NSKeyedUnarchiver.unarchiveObjectWithData(data) as [Stop]
            } else {
                return []
            }
        }
        set {
            let defaults = NSUserDefaults.standardUserDefaults()
            let data = NSKeyedArchiver.archivedDataWithRootObject(newValue)
            defaults.setObject(data, forKey: UserDefaults.favoriteStopsKey)
            defaults.synchronize()
        }
    }

    class func getAllStops() -> [Stop] {
        var stops = [Stop]()
        if let db = GTFSDatabase.open() {
            let query = "select stop_id, stop_name, stop_lat, stop_lon, routes FROM stops"
            let rs = db.executeQuery(query, withArgumentsInArray: nil)
            while rs.next() {
                let stop = Stop()
                stop.stopId = rs.objectForColumnName("stop_id") as? String
                stop.stopName = rs.objectForColumnName("stop_name") as? String
                
                let latitude = rs.objectForColumnName("stop_lat").doubleValue
                let longitude = rs.objectForColumnName("stop_lon").doubleValue
                stop.location = CLLocation(latitude: latitude, longitude: longitude)
                
                stop.routesString = rs.objectForColumnName("routes") as? String
                
                stop.milesAway = 0.0
                
                stops.append(stop)
            }
            rs.close()
            db.close()
        }
        return stops
    }
    
    class func getClosestStops(numStops: Int, location: CLLocation) -> [Stop] {
        let allStops = Stop.getAllStops()
        
        let n = min(numStops, allStops.count)
        
        var stopsSortedByDistance: [Stop] = allStops.sorted { (first, second) -> Bool in
            if let firstLocation = first.location?.distanceFromLocation(location) {
                first.milesAway = firstLocation * Conversions.METERS_IN_A_MILE
            }
            if let secondLocation = second.location?.distanceFromLocation(location) {
                second.milesAway = secondLocation * Conversions.METERS_IN_A_MILE
            }
            
            return first.milesAway < second.milesAway
        }
        
        return [Stop](stopsSortedByDistance[0...n-1])
    }
    
    // MARK: - Fields
    
    var location: CLLocation?
    var stopId: String?
    var stopName: String?
    var routesString: String?
    var milesAway: Double?
    
    // MARK: - Initializers
    
    override init() {
        super.init()
    }

    private func setFieldsUsingStopId(sId: String) {
        if let db = GTFSDatabase.open() {
            let query = "select stop_id, stop_name, stop_lat, stop_lon, routes FROM stops WHERE stop_id=?"
            let rs = db.executeQuery(query, withArgumentsInArray: [sId])
            if rs.next() {
                stopId = rs.objectForColumnName("stop_id") as? String
                stopName = rs.objectForColumnName("stop_name") as? String
                
                let latitude = rs.objectForColumnName("stop_lat").doubleValue
                let longitude = rs.objectForColumnName("stop_lon").doubleValue
                location = CLLocation(latitude: latitude, longitude: longitude)
                routesString = rs.objectForColumnName("routes") as? String
                milesAway = 0.0
            } else {
                rs.close()
                db.close()
            }
            rs.close()
            db.close()
        }
    }

    // MARK: - Favorite stop
    
    var isFavoriteStop: Bool {
        return Stop.favoriteStops.filter({(stop: Stop) -> Bool in
            return stop.stopId == self.stopId
        }).count > 0
    }
    
    // MARK: - NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(stopId, forKey: NSCodingKeys.stopIdKey)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        setFieldsUsingStopId(aDecoder.decodeObjectForKey(NSCodingKeys.stopIdKey) as String)
    }
}
