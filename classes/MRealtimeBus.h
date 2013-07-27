//
//  MBus.h
//  marguerite
//
//  Created by Kevin Conley on 7/22/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MRoute.h"

@interface MRealtimeBus : NSObject

@property (nonatomic, strong) MRoute * route;
@property (nonatomic, strong) NSString * vehicleId;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSDictionary *dictionary;

- (id) initWithVehicleId:(NSString *) vid andRouteId:(NSString *)route_id andLocation:(CLLocation *)loc;

@end
