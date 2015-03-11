//
//  RealtimeBusAnnotation.swift
//  Marguerite
//
//  Created by Kevin Conley on 3/10/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit
import MapKit

class RealtimeBusAnnotation: MKPointAnnotation {
    var color = UIColor()
    var heading: Double = 0.0
    var identifer: String
    
    init(identifer: String) {
        self.identifer = identifer
        super.init()
    }
}