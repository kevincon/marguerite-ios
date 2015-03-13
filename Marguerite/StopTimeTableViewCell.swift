//
//  StopTimeTableViewCell.swift
//  A UITableViewCell for viewing a shuttle departure time.
//
//  Created by Kevin Conley on 3/5/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit

class StopTimeTableViewCell: UITableViewCell {

    // MARK: - Public API
    
    var stopTime: StopTime? {
        didSet {
            routeLabel?.text = " \(stopTime!.displayName) "
            routeLabel?.textColor = stopTime!.routeTextColor
            routeLabel?.backgroundColor = stopTime!.routeColor
            routeLabel?.sizeToFit()
            routeLabel?.layer.cornerRadius = 4
            routeLabel?.layer.masksToBounds = true

            let twelveHourFormat = NSDateFormatter()
            twelveHourFormat.dateFormat = "h:mm a"

            departureTimeLabel?.text = twelveHourFormat.stringFromDate(stopTime!.departureTime!)
        }
    }

    // MARK: - Outlets

    @IBOutlet private weak var routeLabel: UILabel!
    @IBOutlet private weak var departureTimeLabel: UILabel!
}
