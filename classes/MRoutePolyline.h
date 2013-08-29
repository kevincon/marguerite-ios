//
//  MRoutePolyline.h
//  marguerite
//
//  Created by Kevin Conley on 8/26/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "MRoute.h"

@interface MRoutePolyline : GMSPolyline

- (id) initWithRoute:(MRoute *) route;

@end
