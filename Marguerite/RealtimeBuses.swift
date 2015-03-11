//
//  RealtimeBuses.swift
//  Marguerite
//
//  Created by Kevin Conley on 3/8/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit
import CoreLocation

extension NSError {
    class func errorWithString(message: String) -> NSError {
        return NSError(domain: "world", code: 200, userInfo: [NSLocalizedDescriptionKey: message])
    }
}

protocol RealtimeBusesDelegate: class {
    func busUpdateSuccess(buses: [RealtimeBus])
    func busUpdateFailure(error: NSError)
}

class RealtimeBuses: NSObject, NSXMLParserDelegate {
    
    // MARK: - Public API
    
    var urlString: String
    weak var delegate: RealtimeBusesDelegate?
    
    // MARK: - Initializer
    
    init(urlString: String) {
        self.urlString = urlString
    }
    
    /**
    Refresh the buses by downloading the XML feed, asynchronously.
    */
    func update() {
        if let url = NSURL(string: urlString) {
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.value), 0)) { () -> Void in
                if let parser = NSXMLParser(contentsOfURL: url) {
                    parser.delegate = self
                
                    if !parser.parse() {
                        self.delegate?.busUpdateFailure(NSError.errorWithString("Parsing XML failed."))
                    }
                }
            }
        }
    }
    
    // MARK: - NSXMLParserDelegate
    
    private struct XMLElements {
        static let vehicle = "vehicle"
        
        static let commStatus = "comm-status"
        static let gpsStatus = "gps-status"
        static let opStatus = "op-status"
        
        static let goodStatus = "good"
        static let noStatus = "none"
    }
    
    private struct VehicleElements {
        static let name = "name"
        static let routeId = "routeid"
        static let tripId = "tripid"
        static let heading = "heading"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let speed = "speed"
        static let time = "time"
    }
    
    private var parsingVehicle = false
    private var currentElement: String?
    private var vehicleDictionaries = [[String:String]]()
    private var currentVehicleDictionary = [String:String]()
    
    func parserDidStartDocument(parser: NSXMLParser!) {
        vehicleDictionaries.removeAll(keepCapacity: true)
    }
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        if elementName == XMLElements.vehicle {
            if let gpsStatus = attributeDict[XMLElements.gpsStatus] as? String {
                if let opStatus = attributeDict[XMLElements.opStatus] as? String {
                    if gpsStatus == XMLElements.goodStatus {
                        if !parsingVehicle {
                            currentVehicleDictionary.removeAll(keepCapacity: true)
                            parsingVehicle = true
                        }
                    }
                }
            }
        }
        
        currentElement = elementName
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        if parsingVehicle {
            if let current = currentElement {
                currentVehicleDictionary[current] = string
            }
        }
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        if elementName == XMLElements.vehicle {
            if parsingVehicle {
                vehicleDictionaries.append(currentVehicleDictionary)
            }
            parsingVehicle = false
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser!) {
        // Construct vehicle ID string for POST request
        let vehicleIdString = extractVehicleIdsFromBusDictionaries(vehicleDictionaries)
        
        // Perform POST request
        let request = NSMutableURLRequest(URL: NSURL(string: "http://lbre-apps.stanford.edu/marguerite/data/?action=main.getidbyname")!)
        request.HTTPMethod = "POST"
        let postString = "name=\(vehicleIdString)"
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), { (response, data, error) -> Void in
            if error != nil {
                self.delegate?.busUpdateFailure(error)
                return
            }
            
            var jsonError: NSError? = nil
            if let jsonData = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? [String:AnyObject] {
                if let mappings = jsonData["DATA"] as? [[Int]] {
                    var vehicleIdsToFareboxIds = [String:String]()
                    for mapping in mappings {
                        if mapping.count == 2 {
                            vehicleIdsToFareboxIds[String(format: "%d", mapping[0])] = String(format: "%d", mapping[1])
                        }
                    }
                    self.updateBuses(self.vehicleDictionaries, vehicleIdsToFareboxIds: vehicleIdsToFareboxIds)
                } else {
                    self.delegate?.busUpdateFailure(NSError.errorWithString("No data found"))
                }
            } else {
                if jsonError != nil {
                    self.delegate?.busUpdateFailure(jsonError!)
                }
            }
        })
    }
    
    private func extractVehicleIdsFromBusDictionaries(busDictionaries: [[String:String]]) -> String {
        var vehicleIds = [String]()
        
        for busDictionary in busDictionaries {
            if let vehicleId = busDictionary[VehicleElements.name] {
                var id: String = vehicleId
                
                // this is a hack for SMP, following the web-based live map
                if busDictionary[VehicleElements.routeId] == "8888" {
                    id = "8888"
                }
                
                vehicleIds.append(id)
            }
        }
        
        return ",".join(vehicleIds)
    }


    private func updateBuses(busDictionaries: [[String: String]], vehicleIdsToFareboxIds: [String: String]) {
        var updatedBuses = [RealtimeBus]()
        for busDictionary in busDictionaries {
            if let vehicleId = busDictionary[VehicleElements.name] {
                if let fareboxId = vehicleIdsToFareboxIds[vehicleId] {
                    if fareboxId == "-1" {
                        continue
                    } else {
                        if let routeId = getRouteIdWithFareboxId(fareboxId) {
                            if let route = Route(routeId: routeId) {
                                if let latitude = busDictionary[VehicleElements.latitude] {
                                    if let longitude = busDictionary[VehicleElements.longitude] {
                                        
                                        let location = CLLocationCoordinate2D(latitude: (latitude as NSString).doubleValue, longitude: (longitude as NSString).doubleValue)
                                        let bus = RealtimeBus(route: route, vehicleId: vehicleId, location: location)
                                        if let heading = busDictionary[VehicleElements.heading] {
                                            bus.heading = (heading as NSString).doubleValue
                                        }
                                        updatedBuses.append(bus)
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
        }
        self.delegate?.busUpdateSuccess(updatedBuses)
    }
    
    /**
    The XML feed identifies buses using a (mostly) 4-digit ID in the name
    element, called a vehicle ID.
    
    The vehicle ID is translated to a farebox ID using the POST request in
    "updateFareboxIds".
    
    This function translates a farebox ID into the corresponding GTFS route ID.
    
    :param: fareboxId The fareboxId to translate to a GTFS route ID.
    
    :returns: The resulting GTFS route ID, or nil upon failure.
    */
    func getRouteIdWithFareboxId(fareboxId: String) -> String? {
        if let fareboxIdInt = fareboxId.toInt() {
            switch fareboxIdInt {
            case 8888:
                //Stanford Menlo Park
                return "40"
            case 9999:
                //Bohannon
                return "53"
            case 2:
                //Line Y (Clockwise)
                return "2"
            case 3:
                //Line X (Counter-Clockwise)
                return "3"
            case 4:
                //Line C
                return "4"
            case 5:
                //Tech
                return "54"
            case 8:
                //SLAC
                return "8"
            case 9:
                //Line N
                return "9"
            case 10:
                //Line O
                return "43"
            case 11:
                //Shopping Express
                return "18"
            case 15:
                //Line V
                return "15"
            case 17:
                //Line P
                return "20"
            case 19:
                //Medical Center
                return "22"
            case 23:
                //1050 Arastradero
                return "28"
            case 28:
                //Line S
                return "33"
            case 29:
                //Ardenwood Express
                return "36"
            case 30:
                //Research Park
                return "38"
            case 32:
                //Stanford Menlo Park
                return "40"
            case 33:
                //Bohannon
                return "53"
            case 40:
                //Line Y
                return "2"
            case 42:
                //Line Y Limited
                return "44"
            case 43:
                //Line X Limited
                return "45"
            case 44:
                //Line C Limited
                return "46"
            case 46:
                //OCA
                return "56"
            case 47:
                //Electric N
                return "9"
            case 48:
                //Medical Center Limited
                return "47"
            case 49:
                //Medical Center Limited
                return "47"
            case 50:
                //EB ???
                return nil;
            case 51:
                //Electric 1050A
                return "28"
            case 52:
                //Electric BOH
                return "53"
            case 53:
                //Electric Y
                return "2"
            case 54:
                //Electric C
                return "4"
            case 55:
                //Electric MC
                return "22"
            case 56:
                //Electric MC-H
                return "50"
            case 57:
                //Electric O
                return "43"
            case 58:
                //Electric P
                return "20"
            case 59:
                //Electric RP
                return "38"
            case 60:
                //Electric SE
                return "18"
            case 61:
                //Electric SLAC
                return "8"
            case 62:
                //Electric SMP
                return "40"
            case 63:
                //Electric TECH
                return "54"
            case 64:
                //Electric V
                return "15"
            case 65:
                //Electric X
                return "3"
            default:
                return nil
            }
        } else {
            return nil
        }
    }
}
