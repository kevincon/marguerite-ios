//
//  LiveMapViewController.swift
//  Marguerite
//
//  Created by Kevin Conley on 3/3/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit
import MapKit

class LiveMapViewController: UIViewController {

    @IBOutlet weak var liveMapView: LiveMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        liveMapView.zoomToStanford()
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    @IBAction func zoomToUserLocationButtonTapped() {
        liveMapView.zoomToUserLocation()
    }

    @IBAction func zoomToStanfordButtonTapped() {
        liveMapView.zoomToStanford()
    }
}
