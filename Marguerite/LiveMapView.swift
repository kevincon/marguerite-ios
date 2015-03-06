//
//  LiveMapView.swift
//  Marguerite
//
//  Created by Kevin Conley on 3/3/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit
import MapKit

class LiveMapView: MKMapView {

    let STANFORD_LATITUDE = 37.432233
    let STANFORD_LONGITUDE = -122.171183
    let STANFORD_LATITUDE_LONGITUDE_SPAN = 0.03
    
    func zoomToUserLocation() {
        setCenterCoordinate(userLocation.coordinate, animated: true)
    }
    
    func zoomToStanford() {
        let stanfordCenter = CLLocationCoordinate2DMake(STANFORD_LATITUDE, STANFORD_LONGITUDE)
        let stanfordSpan = MKCoordinateSpanMake(STANFORD_LATITUDE_LONGITUDE_SPAN, STANFORD_LATITUDE_LONGITUDE_SPAN)
        let stanfordRegion = MKCoordinateRegionMake(stanfordCenter, stanfordSpan)
        setRegion(stanfordRegion, animated: true)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
