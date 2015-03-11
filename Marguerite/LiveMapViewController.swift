//
//  LiveMapViewController.swift
//  Marguerite
//
//  Created by Kevin Conley on 3/3/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit
import MapKit

class LiveMapViewController: UIViewController, MKMapViewDelegate, RealtimeBusesDelegate {
    
    var realtimeBuses = RealtimeBuses(urlString: "http://lbre-apps.stanford.edu/transportation/stanford_ivl/locations.cfm")
    
    private var busMarkers = [String: RealtimeBusAnnotation]()
    private var timer = NSTimer()
    private let busRefreshInterval = 3.0
    private var timerShouldRepeat = true
    private var noBusesRunning = false
    private var busLoadError = false
    
    // MARK: - Outlets
    
    @IBOutlet weak var liveMapView: LiveMapView!

    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        zoomToStanford()
        realtimeBuses.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        showHUDWithMessage("Loading buses...", withActivity: true)
        timerShouldRepeat = true
        refreshBuses()
    }
    
    override func viewWillDisappear(animated: Bool) {
        hideHUD()
        timer.invalidate()
        timerShouldRepeat = false
    }
    
    // MARK: - Realtime Bus Drawing
    
    func refreshBuses() {
        realtimeBuses.update()
    }
    
    func updateMarkerWithBus(bus: RealtimeBus) {
        if let existingMarker = self.busMarkers[bus.vehicleId] {
            existingMarker.title = bus.route.routeShortName
            existingMarker.subtitle = bus.route.routeLongName
            existingMarker.heading = bus.heading
            existingMarker.color = bus.route.routeColor
            
            let markerView = liveMapView.viewForAnnotation(existingMarker)
            if let busView = markerView as? RealtimeBusAnnotationView {
                UIView.animateWithDuration(0.8, animations: { () -> Void in
                    busView.updateArrowImageRotation()
                    existingMarker.coordinate = bus.location
                })
            }
        } else {
            let marker = RealtimeBusAnnotation(identifer: bus.vehicleId)
            self.busMarkers[bus.vehicleId] = marker
            
            marker.title = bus.route.routeShortName
            marker.subtitle = bus.route.routeLongName
            marker.heading = bus.heading
            marker.color = bus.route.routeColor
            
            marker.coordinate = bus.location
            
            self.liveMapView.addAnnotation(marker)
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let busAnnotation = annotation as? RealtimeBusAnnotation {
            var busView = mapView.dequeueReusableAnnotationViewWithIdentifier(busAnnotation.identifer) as? RealtimeBusAnnotationView
            if busView == nil {
                busView = RealtimeBusAnnotationView(annotation: annotation, reuseIdentifier: busAnnotation.identifer)
            }
            busView!.annotation = annotation
            return busView!
        }
        return nil
    }
    
    // MARK: - RealtimeBusesDelegate
    
    func busUpdateSuccess(buses: [RealtimeBus]) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if buses.count > 0 {
                for bus in buses {
                    self.updateMarkerWithBus(bus)
                }
                self.hideHUD()
                self.noBusesRunning = false
                self.busLoadError = false
            } else {
                if !self.noBusesRunning {
                    self.showHUDWithMessage("No buses are reporting locations.", withActivity: false)
                }
                self.noBusesRunning = true;
                self.busLoadError = false
            }
            if self.timerShouldRepeat {
                self.timer = NSTimer(timeInterval: self.busRefreshInterval, target: self, selector: Selector("refreshBuses"), userInfo: nil, repeats: false)
                NSRunLoop.mainRunLoop().addTimer(self.timer, forMode: NSRunLoopCommonModes)
            }
        })
    }
    
    func busUpdateFailure(error: NSError) {
        println(error)
        if !busLoadError {
            self.showHUDWithMessage("Could not connect to bus server.", withActivity: false)
        }
        noBusesRunning = false
        busLoadError = true
        if self.timerShouldRepeat {
            self.timer = NSTimer(timeInterval: self.busRefreshInterval, target: self, selector: Selector("refreshBuses"), userInfo: nil, repeats: false)
            NSRunLoop.mainRunLoop().addTimer(self.timer, forMode: NSRunLoopCommonModes)
        }
    }

    // MARK: - Map zooming
    
    let STANFORD_LATITUDE = 37.432233
    let STANFORD_LONGITUDE = -122.171183
    let STANFORD_LATITUDE_LONGITUDE_SPAN = 0.03
    
    @IBAction func zoomToUserLocation() {
        liveMapView.setCenterCoordinate(liveMapView.userLocation.coordinate, animated: true)
    }
    
    @IBAction func zoomToStanford() {
        let stanfordCenter = CLLocationCoordinate2DMake(STANFORD_LATITUDE, STANFORD_LONGITUDE)
        let stanfordSpan = MKCoordinateSpanMake(STANFORD_LATITUDE_LONGITUDE_SPAN, STANFORD_LATITUDE_LONGITUDE_SPAN)
        let stanfordRegion = MKCoordinateRegionMake(stanfordCenter, stanfordSpan)
        liveMapView.setRegion(stanfordRegion, animated: true)
    }

    // MARK: - HUD
    private var HUD: GCDiscreetNotificationView!

    private func showHUDWithMessage(message: String, withActivity: Bool) {
        if HUD == nil {
            HUD = GCDiscreetNotificationView(text: message, showActivity: withActivity, inPresentationMode: GCDiscreetNotificationViewPresentationModeTop, inView: self.liveMapView)
        }

        HUD.textLabel = message
        HUD.showActivity = withActivity
        HUD.show(true)
    }

    private func hideHUD() {
        HUD.hide(true)
    }

}
