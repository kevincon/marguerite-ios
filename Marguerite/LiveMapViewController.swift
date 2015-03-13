//
//  LiveMapViewController.swift
//  A UIViewController for displaying real-time shuttle buses and stops on
//  an MKMapView.
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

    // MARK: - Storyboard constants

    private struct Storyboard {
        static let stopSegue = "ShowStopFromMapSegue"
        static let loadingBusesText = "Loading buses..."
        static let stopSubtitleText = "Tap here to view next shuttle times."
        static let noBusesText = "No buses are reporting locations."
        static let busServerErrorText = "Could not connect to bus server."
        static let stopAnnotationViewIdentifier = "StopAnnotationView"
    }

    // MARK: - Outlets
    
    @IBOutlet private weak var liveMapView: MKMapView! {
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
        showHUDWithMessage(Storyboard.loadingBusesText, withActivity: true)
        timerShouldRepeat = true
        noBusesRunning = false
        busLoadError = false

        // Zoom to a stop, if necessary
        if stopToZoomTo != nil {
            zoomToStop(stopToZoomTo!)
            stopToZoomTo = nil
        }

        refreshBuses()
    }
    
    override func viewWillDisappear(animated: Bool) {
        hideHUD()
        timer.invalidate()
        timerShouldRepeat = false
    }
    
    // MARK: - Real-time Bus Drawing

    /**
    Refresh the buses on the map.
    */
    func refreshBuses() {
        realtimeBuses.update()
    }

    /**
    Update annotations on the map with new bus information.

    :param: bus The new bus information.
    */
    private func updateMarkerWithBus(bus: RealtimeBus) {
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

    /**
    *  An MKPointAnnotation for a stop on the live map.
    *  (only used in this class and too small for a separate file)
    */
    private class StopAnnotation: MKPointAnnotation {
        var stop: Stop?
    }

    /**
    Load all of the stops from the GTFS data on the live map.
    */
    private func loadStops() {
        let allStops = Stop.getAllStops()
        for stop in allStops {
            let marker = StopAnnotation()
            marker.title = stop.stopName
            marker.subtitle = Storyboard.stopSubtitleText
            marker.coordinate = stop.location!.coordinate
            marker.stop = stop
            stopMarkers[stop.stopId!] = marker
            liveMapView.addAnnotation(marker)
        }
    }

    // MARK: - MKMapViewDelegate

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let busAnnotation = annotation as? RealtimeBusAnnotation {
            var busView = mapView.dequeueReusableAnnotationViewWithIdentifier(busAnnotation.identifer) as? RealtimeBusAnnotationView
            if busView == nil {
                busView = RealtimeBusAnnotationView(annotation: annotation, reuseIdentifier: busAnnotation.identifer)
            }
            busView!.annotation = annotation
            return busView!
        } else if let stopAnnotation = annotation as? StopAnnotation {
            var stopView = mapView.dequeueReusableAnnotationViewWithIdentifier(Storyboard.stopAnnotationViewIdentifier)
            if stopView == nil {
                stopView = MKAnnotationView(annotation: stopAnnotation, reuseIdentifier: Storyboard.stopAnnotationViewIdentifier)
                let circleRadius: CGFloat = 3.0
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

                self.hideHUD()
                self.noBusesRunning = false
                self.busLoadError = false
            } else {
                if !self.noBusesRunning {
                    self.showHUDWithMessage(Storyboard.noBusesText, withActivity: false)
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
                self.showHUDWithMessage(Storyboard.busServerErrorText, withActivity: false)
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

    private let stanfordRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.432233, -122.171183), MKCoordinateSpanMake(0.03, 0.03))
    
    @IBAction func zoomToUserLocation() {
        liveMapView.setCenterCoordinate(liveMapView.userLocation.coordinate, animated: true)
    }
    
    @IBAction func zoomToStanford() {
        liveMapView.setRegion(stanfordRegion, animated: true)
    }

    private func zoomToStop(stop: Stop) {
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
