//
//  LiveMapViewController.m
//  marguerite
//
//  Created by Kevin Conley on 7/16/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "LiveMapViewController.h"
#import "RealtimeBuses.h"
#import "MRealtimeBus.h"
#import "MRoutePolyline.h"
#import <CoreLocation/CoreLocation.h>
#import "secrets.h"
#import "Util.h"

#define STANFORD_LATITUDE       37.432233
#define STANFORD_LONGITUDE      -122.171183
#define STANFORD_ZOOM_LEVEL     14

@interface LiveMapViewController ()

@end

@implementation LiveMapViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
	
    busMarkers = [[NSMutableDictionary alloc] init];
    buses = [[RealtimeBuses alloc] initWithURL:MARGUERITE_REALTIME_XML_FEED
                            andSuccessCallback:^(NSArray *busesArray) {
                                for (MRealtimeBus *bus in busesArray) {
                                    [self updateMarkerWithBus:bus];
                                }
                            }
                            andFailureCallback:^(NSError *error) {
                                return;
                            }];
    
    [_mapView setCamera:[GMSCameraPosition cameraWithLatitude:STANFORD_LATITUDE longitude:STANFORD_LONGITUDE zoom:STANFORD_ZOOM_LEVEL]];
    _mapView.delegate = self;
    _mapView.mapType = kGMSTypeNormal;
    _mapView.myLocationEnabled = YES;
    _mapView.settings.zoomGestures = YES;
    _mapView.settings.myLocationButton = YES;
    
    // Manually insert the "Zoom to Stanford" button
    [_mapView addSubview:_stanfordButton];
    
    routePolyline = nil;
    
    // Update the bus locations immediately for the first time
    [buses update];
    
    // Set up a timer to update the bus locations every 5 seconds
    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
}

- (void) timerCallback
{
    [buses update];
}

- (void) updateMarkerWithBus:(MRealtimeBus *)bus
{
    GMSMarker *marker = busMarkers[bus.vehicleId];
    if (marker == nil) {
        marker = [[GMSMarker alloc] init];
    }
    marker.position = [bus.location coordinate];
    marker.icon = [self getImageForRouteId:bus.route.routeId];
    marker.title = bus.route.routeShortName;
    marker.snippet = bus.route.routeLongName;
    marker.map = _mapView;
    marker.animated = YES;
    marker.userData = bus;
    busMarkers[bus.vehicleId] = marker;
}

- (void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    // Clear route polyline if one is being displayed
    if (routePolyline != nil) {
        routePolyline.map = nil;
        routePolyline = nil;
    }
}

- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    // Clear route polyline if one is being displayed
    if (routePolyline != nil) {
        routePolyline.map = nil;
        routePolyline = nil;
    }
    if (marker.userData != nil) {
        MRoute *route = ((MRealtimeBus *)marker.userData).route;
        routePolyline = [[MRoutePolyline alloc] initWithRoute:route];
        if (routePolyline != nil) {
            routePolyline.map = _mapView;
        }
    }
    
    
    // Map should then continue with its default selection behavior
    return NO;
}

/*
 Get the image to show as a marker on the map for the given gtfs
 route_id. Returns nil if route is not recognized.
 */
- (UIImage *) getImageForRouteId:(NSString *)route_id
{
    NSString *imageFileName = nil;
    switch ([route_id integerValue]) {
        case 2:
            //Y
            imageFileName = @"Y";
            break;
        case 3:
            //X
            imageFileName = @"X";
            break;
        case 4:
            //C
            imageFileName = @"C";
            break;
        case 8:
            //SLAC
            imageFileName = @"SLAC";
            break;
        case 9:
            //N
            imageFileName = @"N";
            break;
        case 15:
            //V
            imageFileName = @"V";
            break;
        case 18:
            //SE
            imageFileName = @"SE";
            break;
        case 20:
            //P
            imageFileName = @"P";
            break;
        case 22:
            //MC
            imageFileName = @"MC";
            break;
        case 28:
            //1050A
            imageFileName = @"1050A";
            break;
        case 33:
            //S
            imageFileName = @"S";
            break;
        case 36:
            //AWE
            imageFileName = @"AE";
            break;
        case 38:
            //RP
            imageFileName = @"RP";
            break;
        case 40:
            //SMP
            imageFileName = @"SMP";
            break;
        case 43:
            //O
            imageFileName = @"O";
            break;
        case 44:
            //Y-lim
            imageFileName = @"Y";
            break;
        case 45:
            //X-lim
            imageFileName = @"X";
            break;
        case 46:
            //C-lim
            imageFileName = @"C";
            break;
        case 47:
            //MC-lim
            imageFileName = @"MC";
            break;
        case 48:
            //MC-direct
            imageFileName = @"MC";
            break;
        case 50:
            //MC-holiday
            imageFileName = @"MC";
            break;
        case 51:
            //Line x express
            imageFileName = @"X";
            break;
        case 52:
            //line y express
            imageFileName = @"Y";
            break;
        case 53:
            //BOH
            imageFileName = @"BOH";
            break;
        case 54:
            //TECH
            imageFileName = @"TECH";
            break;
        case 55:
            //East Bay Express
            imageFileName = @"EB";
            break;
        case 56:
            //OCA
            imageFileName = @"OCA";
            break;
        default:
            imageFileName = nil;
    }
    
    if (imageFileName == nil) {
        return nil;
    }
    
    NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:imageFileName ofType:@"png"];
    
    return [UIImage imageWithContentsOfFile:imageFilePath];
}

- (IBAction)zoomToCampus:(id)sender {
    [_mapView animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:STANFORD_LATITUDE
                                                                  longitude:STANFORD_LONGITUDE
                                                                       zoom:STANFORD_ZOOM_LEVEL]];
}

@end
