//
//  LiveMapViewController.h
//  marguerite
//
//  Created by Kevin Conley on 7/16/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RealtimeBuses.h"
#import "MRoutePolyline.h"
#import <GoogleMaps/GoogleMaps.h>

@interface LiveMapViewController : UIViewController <GMSMapViewDelegate> {
    RealtimeBuses *buses;
    NSMutableDictionary *busMarkers;
    NSTimer *timer;
    MRoutePolyline *routePolyline;
}

@property (weak, nonatomic) GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *stanfordButton;

- (IBAction)zoomToCampus:(id)sender;

@end
