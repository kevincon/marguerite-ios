//
//  UIImage+Extras.swift
//  Marguerite
//
//  Created by Kevin Conley on 3/12/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit

extension UIImage {
    class func circleWithRadius(radius: CGFloat, color: UIColor) -> UIImage {
        let diameter = radius * 2
        let size = CGSize(width: diameter, height: diameter)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSaveGState(ctx)

        let rect = CGRect(origin: CGPointZero, size: size)
        CGContextSetFillColorWithColor(ctx, color.CGColor)
        CGContextFillEllipseInRect(ctx, rect)

        CGContextRestoreGState(ctx)
        let circleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return circleImage
    }
}