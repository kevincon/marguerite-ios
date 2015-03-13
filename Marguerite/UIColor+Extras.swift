//
//  UIColor+Extras.swift
//  UIColor extensions.
//
//  Created by Kevin Conley on 3/4/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit

extension UIColor {
    /**
    The Stanford red color.

    :returns: The Stanford red color.
    */
    class func stanfordRedColor() -> UIColor {
        return colorFromHexString("8C1515")
    }

    /**
    Convert a hex string to a UIColor.

    :param: hexString The hex string to convert.

    :returns: The resulting UIColor.
    */
    class func colorFromHexString(hexString: String) -> UIColor {
        var rgbValue: UInt32 = 0
        let scanner = NSScanner(string: hexString)
        scanner.scanHexInt(&rgbValue)
        
        let red = CGFloat(((rgbValue & 0xFF0000) >> 16)) / 255.0
        let green = CGFloat(((rgbValue & 0xFF00) >> 8)) / 255.0
        let blue = CGFloat(rgbValue & 0xFF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}