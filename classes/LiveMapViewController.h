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
#import "GCDiscreetNotificationView.h"

@interface LiveMapViewController : UIViewController <GMSMapViewDelegate> {
    RealtimeBuses *buses;
    NSMutableDictionary *busMarkers;
    NSTimer *timer;
    MRoutePolyline *routePolyline;
    BOOL noBusesRunning;
    BOOL busLoadError;
}

@property (weak, nonatomic) GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *stanfordButton;
@property (strong, nonatomic) GCDiscreetNotificationView *HUD;

- (IBAction)zoomToCampus:(id)sender;

@end
