//
//  CoreLocationController.swift
//  Marguerite
//
//  Created by Kevin Conley on 3/2/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit
import CoreLocation

protocol CoreLocationControllerDelegate: class {
    func locationUpdate(location: CLLocation)
    func locationError(error: NSError)
}

class CoreLocationController: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    weak var delegate: CoreLocationControllerDelegate?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func refreshLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        delegate?.locationUpdate(newLocation)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        delegate?.locationError(error)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}
