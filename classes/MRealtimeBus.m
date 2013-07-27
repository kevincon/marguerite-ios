//
//  MBus.m
//  marguerite
//
//  Created by Kevin Conley on 7/22/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "MRealtimeBus.h"
#import "MRoute.h"
#import <CoreLocation/CoreLocation.h>

@implementation MRealtimeBus

/*
 Create a "real-time" MBus object by looking up the route in the GTFS database. Returns nil if 
 the route does not exist.
 */
- (id) initWithVehicleId:(NSString *) vid andRouteId:(NSString *)route_id andLocation:(CLLocation *)loc
{
    if (self = [super init]) {
        self.vehicleId = vid;
        self.route = [[MRoute alloc] initWithRouteIdString:route_id];
        if (self.route == nil) {
            return nil;
        }
        self.location = loc;
    }
    return self;
}

@end
