//
//  RealtimeBusAnnotationView.swift
//  Marguerite
//
//  Created by Kevin Conley on 3/10/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit
import MapKit

class RealtimeBusAnnotationView: MKAnnotationView {

    let arrowImageView: UIImageView?
    let identiferLabel: UILabel?
    
    override init!(annotation: MKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        if !(annotation is RealtimeBusAnnotation) {
            let e = NSException(name:NSInvalidArgumentException, reason:"RealtimeBusAnnotationView requires annotation of type RealtimeBusAnnotation", userInfo:nil)
            e.raise()
        }
        
        let busAnnotation = annotation as RealtimeBusAnnotation
        let arrowImage = UIImage(named: "arrow")!.imageWithRenderingMode(.AlwaysTemplate)
        arrowImageView = UIImageView(image: arrowImage)
        arrowImageView?.tintColor = busAnnotation.color
        updateArrowImageRotation()
        addSubview(arrowImageView!)
        
        self.frame = arrowImageView!.bounds
        
        identiferLabel = UILabel()
        identiferLabel?.textColor = busAnnotation.textColor
        identiferLabel?.font = UIFont(name: "Menlo-Bold", size: 12.0)
        identiferLabel?.text = " \(busAnnotation.title) "
        identiferLabel?.textAlignment = NSTextAlignment.Left
        identiferLabel?.backgroundColor = busAnnotation.color
        identiferLabel?.layer.cornerRadius = 4
        identiferLabel?.layer.masksToBounds = true
        addSubview(identiferLabel!)
        
        identiferLabel?.setTranslatesAutoresizingMaskIntoConstraints(false)
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: identiferLabel!, attribute: .CenterX, relatedBy: .Equal, toItem: arrowImageView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(item: identiferLabel!, attribute: .CenterY, relatedBy: .Equal, toItem: arrowImageView, attribute: .Top, multiplier: 1.0, constant: -6.0))
        addConstraints(constraints)
    }
    
    func DEGREES_TO_RADIANS(angle: Double) -> CGFloat {
        return CGFloat((angle) / 180.0 * M_PI)
    }
    
    func updateArrowImageRotation() {
        let busAnnotation = self.annotation as RealtimeBusAnnotation
        arrowImageView?.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(busAnnotation.heading));
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
