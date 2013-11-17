//
//  LiveMapViewController.m
//  marguerite
//
//  Created by Kevin Conley on 7/16/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "LiveMapViewController.h"
#import "StopViewController.h"
#import "RealtimeBuses.h"
#import "MRealtimeBus.h"
#import "MRoutePolyline.h"
#import "MStop.h"
#import <CoreLocation/CoreLocation.h>
#import "secrets.h"
#import "Util.h"
#import "GCDiscreetNotificationView.h"

#define STANFORD_LATITUDE                   37.432233
#define STANFORD_LONGITUDE                  -122.171183
#define STANFORD_ZOOM_LEVEL                 14
#define STOP_ZOOM_LEVEL                     15

#define BUS_REFRESH_INTERVAL_IN_SECONDS     5

@interface LiveMapViewController ()

@end

@implementation LiveMapViewController

@synthesize stopToZoomTo;

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}

- (void) viewDidLoad
{
    [super viewDidLoad];
	
    busMarkers = [[NSMutableDictionary alloc] init];
    buses = [[RealtimeBuses alloc] initWithURL:MARGUERITE_REALTIME_XML_FEED
                            andSuccessCallback:^(NSArray *busesArray) {
                                if ([busesArray count] > 0) {
                                    for (MRealtimeBus *bus in busesArray) {
                                        [self updateMarkerWithBus:bus];
                                    }
                                    [self hideHUD];
                                    noBusesRunning = NO;
                                    busLoadError = NO;
                                } else {
                                    if (!noBusesRunning) {
                                        [self showHUDWithMessage:@"No buses are reporting locations." withActivity:NO];
                                    }
                                    noBusesRunning = YES;
                                    busLoadError = NO;
                                }
                                timer = [NSTimer timerWithTimeInterval:BUS_REFRESH_INTERVAL_IN_SECONDS target:self selector:@selector(refreshBuses:) userInfo:nil repeats:NO];
                                [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
                            }
                            andFailureCallback:^(NSError *error) {
                                timer = [NSTimer timerWithTimeInterval:BUS_REFRESH_INTERVAL_IN_SECONDS target:self selector:@selector(refreshBuses:) userInfo:nil repeats:NO];
                                [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
                                if (!busLoadError) {
                                    [self showHUDWithMessage:@"Could not connect to bus server." withActivity:NO];
                                }
                                noBusesRunning = NO;
                                busLoadError = YES;
                            }];
    
    [_mapView setCamera:[GMSCameraPosition cameraWithLatitude:STANFORD_LATITUDE longitude:STANFORD_LONGITUDE zoom:STANFORD_ZOOM_LEVEL]];
    _mapView.delegate = self;
    _mapView.mapType = kGMSTypeNormal;
    _mapView.myLocationEnabled = YES;
    _mapView.settings.zoomGestures = YES;
    _mapView.settings.myLocationButton = YES;
    
    // Manually insert the "Zoom to Stanford" button
    [_mapView addSubview:_stanfordButton];
    
    [self loadStops];
    
    if (stopToZoomTo != nil) {
        [self zoomToStop:stopToZoomTo];
        stopToZoomTo = nil;
    }
    
    [self showHUDWithMessage:@"Loading buses..." withActivity:YES];
    [self refreshBuses:nil];
    
    routePolyline = nil;
}

- (void) loadStops
{
    NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"Stop" ofType:@"png"];
    UIImage *stopIcon = [UIImage imageWithContentsOfFile:imageFilePath];
    
    NSArray *allStops = [MStop getAllStops];
    stopMarkers = [[NSMutableDictionary alloc] init];
    for (MStop *stop in allStops) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = [stop.location coordinate];
        marker.icon = stopIcon;
        marker.title = stop.stopName;
        marker.snippet = @"Tap here to view next shuttles.";
        marker.map = _mapView;
        marker.animated = YES;
        marker.userData = stop;
        marker.zIndex = 0;
        [stopMarkers setObject:marker forKey:stop.stopId];
    }
}

- (void) refreshBuses:(NSTimer *)timer
{
    [buses update];
}

- (void) showHUDWithMessage:(NSString *)message withActivity:(BOOL)activity
{
    if (self.HUD == nil) {
        self.HUD = [[GCDiscreetNotificationView alloc] initWithText:message showActivity:activity inPresentationMode:GCDiscreetNotificationViewPresentationModeTop inView:self.view];
    }
    
    // Setup HUD
    [self.HUD setTextLabel:message];
    [self.HUD setShowActivity:activity animated:YES];
    
    // Show the HUD
    [self.HUD show:YES];
}

- (void) hideHUD
{
    [self.HUD hide:YES];
    self.HUD = nil;
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
    marker.zIndex = 3;
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


- (void) mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    if (marker.userData != nil && [marker.userData isKindOfClass:[MStop class]]) {
        MStop *stop = (MStop *) marker.userData;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        StopViewController *stopViewController = (StopViewController *) [storyboard instantiateViewControllerWithIdentifier:@"StopView"];
        stopViewController.stop = stop;
        [self.navigationController pushViewController:stopViewController animated:YES];
    }
}

- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    // Clear route polyline if one is being displayed
    if (routePolyline != nil) {
        routePolyline.map = nil;
        routePolyline = nil;
    }
    
    if (marker.userData != nil && [marker.userData isKindOfClass:[MRealtimeBus class]]) {
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
        case 43:
            //O
            imageFileName = @"O";
            break;
        case 44:
            //Y-lim
            imageFileName = @"Y-LIM";
            break;
        case 45:
            //X-lim
            imageFileName = @"X-LIM";
            break;
        case 46:
            //C-lim
            imageFileName = @"C";
            break;
        case 48:
            //MC-direct
            imageFileName = @"MC-DIR";
            break;
        case 50:
            //MC-holiday
            imageFileName = @"MC-HOL";
            break;
        case 51:
            //Line x express
            imageFileName = @"X-EXP";
            break;
        case 52:
            //line y express
            imageFileName = @"Y-EXP";
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
            imageFileName = @"EB-EX";
            break;
        case 56:
            //OCA
            imageFileName = @"OCA";
            break;
        case 57:
            //H
            imageFileName = @"H";
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

- (void)zoomToStop:(MStop *)stop {
    GMSMarker *marker = [stopMarkers objectForKey:stop.stopId];
    if (marker == nil) {
        return;
    }
    _mapView.selectedMarker = marker;
    [_mapView animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:marker.position.latitude
                                                                  longitude:marker.position.longitude
                                                                       zoom:STOP_ZOOM_LEVEL]];
}

@end
