//
//  MStop.h
//  marguerite
//
//  Created by Kevin Conley on 7/23/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MStop : NSObject <NSCoding>

@property (nonatomic, strong) CLLocation * location;
@property (nonatomic, strong) NSString * stopId;
@property (nonatomic, strong) NSString * stopName;
@property (nonatomic, strong) NSString * routesString;
@property double milesAway;

- (id) initWithStopId:(NSString *)stop_id;
- (BOOL) isFavoriteStop;
+ (NSMutableArray *) getFavoriteStops;
+ (void) setFavoriteStops:(NSArray *)stops;
+ (NSArray *) getAllStops;
+ (NSArray *)getClosestStops:(int)numStops withLocation:(CLLocation *)location;

@end
