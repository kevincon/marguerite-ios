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

    // MARK: - Public API

    var stopToZoomTo: Stop?

    // MARK: - Private API

    private var realtimeBuses = RealtimeBuses(urlString: "http://lbre-apps.stanford.edu/transportation/stanford_ivl/locations.cfm")
    
    private var busMarkers = [String: RealtimeBusAnnotation]()
    private var stopMarkers = [String: StopAnnotation]()
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

        realtimeBuses.delegate = self

        loadStops()
        zoomToStanford()
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = true
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
            existingMarker.textColor = bus.route.routeTextColor
            
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
            marker.textColor = bus.route.routeTextColor

            marker.coordinate = bus.location
            
            self.liveMapView.addAnnotation(marker)
        }
    }

    // MARK: - Stop Drawing

    class StopAnnotation: MKPointAnnotation {
        var stop: Stop?
    }

    func loadStops() {
        let allStops = Stop.getAllStops()
        for stop in allStops {
            let marker = StopAnnotation()
            marker.title = stop.stopName
            marker.subtitle = "Tap here to view next shuttle times."
            marker.coordinate = stop.location!.coordinate
            marker.stop = stop
            stopMarkers[stop.stopId!] = marker
            liveMapView.addAnnotation(marker)
        }
    }

    // MARK: - MKMapViewDelegate

    struct Storyboard {
        static let stopSegue = "ShowStopFromMapSegue"
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let busAnnotation = annotation as? RealtimeBusAnnotation {
            var busView = mapView.dequeueReusableAnnotationViewWithIdentifier(busAnnotation.identifer) as? RealtimeBusAnnotationView
            if busView == nil {
                busView = RealtimeBusAnnotationView(annotation: annotation, reuseIdentifier: busAnnotation.identifer)
            }
            busView!.annotation = annotation
            return busView!
        } else if let stopAnnotation = annotation as? StopAnnotation {
            var stopView = mapView.dequeueReusableAnnotationViewWithIdentifier("StopAnnotationView")
            if stopView == nil {
                stopView = MKAnnotationView(annotation: stopAnnotation, reuseIdentifier: "StopAnnotationView")
                let circleRadius: CGFloat = 2.0
                let circleImage = UIImage.circleWithRadius(circleRadius, color: UIColor.stanfordRedColor())
                stopView?.image = circleImage
                stopView?.canShowCallout = true
                stopView?.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.InfoLight) as UIView
            }
            stopView!.annotation = annotation
            return stopView!
        }
        return nil
    }

    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        performSegueWithIdentifier(Storyboard.stopSegue, sender: self)
    }

    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        // Move all stop annotation views below everything else
        for v in views {
            if let annotationView = v as? MKAnnotationView {
                if let stopAnnotation = annotationView.annotation as? StopAnnotation {
                    annotationView.layer.zPosition = -1
                }
            }
        }
    }

    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        // Move stop annotation views up when selected so callout doesn't appear
        // below other annotation views
        if let stopAnnotation = view.annotation as? StopAnnotation {
            view.layer.zPosition = 0
        }
    }

    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        // Move stop annotation views below everything when callout is deselected
        if let stopAnnotation = view.annotation as? StopAnnotation {
            view.layer.zPosition = -1
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let svc = segue.destinationViewController as? StopViewController {
            if let selectedAnnotation = liveMapView.selectedAnnotations.first as? StopAnnotation {
                if let stop = selectedAnnotation.stop {
                    svc.stop = stop
                }
            }
        }
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
                // TODO this doesn't work
//                for vehicleId in self.busMarkers.keys {
//                    if buses.filter({(bus: RealtimeBus) -> Bool in
//                        return bus.vehicleId == vehicleId
//                    }).count == 0 {
//                        self.liveMapView.removeAnnotation(self.busMarkers[vehicleId])
//                        self.busMarkers[vehicleId] = nil
//                    }
//                }

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

            // Wait to zoom to a stop until after we've loaded buses
            if self.stopToZoomTo != nil {
                self.zoomToStop(self.stopToZoomTo!)
                self.stopToZoomTo = nil
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
            // Wait to zoom to a stop until after we've tried to load buses
            if self.stopToZoomTo != nil {
                self.zoomToStop(self.stopToZoomTo!)
                self.stopToZoomTo = nil
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

    func zoomToStop(stop: Stop) {
        if let marker = stopMarkers[stop.stopId!] {
            liveMapView.setCenterCoordinate(marker.coordinate, animated: true)
            liveMapView.selectAnnotation(marker, animated: true)
        }
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
