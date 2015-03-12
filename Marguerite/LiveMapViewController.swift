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
    
    @IBOutlet weak var liveMapView: LiveMapView! {
        didSet {
            HUD = GCDiscreetNotificationView(text: "", showActivity: false, inPresentationMode: GCDiscreetNotificationViewPresentationModeTop, inView: liveMapView)
        }
    }

    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        zoomToStanford()
        realtimeBuses.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        showHUDWithMessage("Loading buses...", withActivity: true)
        timerShouldRepeat = true
        noBusesRunning = false
        busLoadError = false
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
                // Add/update bus markers using result list
                for bus in buses {
                    self.updateMarkerWithBus(bus)
                }

                // Remove existing bus markers that are no longer in the result list
                for vehicleId in self.busMarkers.keys {
                    if buses.filter({(bus: RealtimeBus) -> Bool in
                        return bus.vehicleId == vehicleId
                    }).count == 0 {
                        self.liveMapView.removeAnnotation(self.busMarkers[vehicleId])
                        self.busMarkers[vehicleId] = nil
                    }
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
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            println(error)
            if !self.busLoadError {
                self.showHUDWithMessage("Could not connect to bus server.", withActivity: false)
            }
            self.noBusesRunning = false
            self.busLoadError = true
            if self.timerShouldRepeat {
                self.timer = NSTimer(timeInterval: self.busRefreshInterval, target: self, selector: Selector("refreshBuses"), userInfo: nil, repeats: false)
                NSRunLoop.mainRunLoop().addTimer(self.timer, forMode: NSRunLoopCommonModes)
            }
        })
    }

    // MARK: - Map zooming

    let stanfordRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.432233, -122.171183), MKCoordinateSpanMake(0.03, 0.03))
    
    @IBAction func zoomToUserLocation() {
        liveMapView.setCenterCoordinate(liveMapView.userLocation.coordinate, animated: true)
    }
    
    @IBAction func zoomToStanford() {
        liveMapView.setRegion(stanfordRegion, animated: true)
    }

    // MARK: - HUD

    private var HUD: GCDiscreetNotificationView!

    private func showHUDWithMessage(message: String, withActivity: Bool) {
        HUD.textLabel = message
        HUD.showActivity = withActivity
        HUD.show(true)
    }

    private func hideHUD() {
        HUD.hide(true)
    }

}
