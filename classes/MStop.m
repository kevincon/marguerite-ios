//
//  MStop.m
//  marguerite
//
//  Created by Kevin Conley on 7/23/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "MStop.h"
#import "MRoute.h"
#import "GTFSDatabase.h"

#define METERS_IN_A_MILE 0.000621371

@implementation MStop

/*
 Return an MStop object by looking up the given stop_id in the GTFS database.
 */
- (id) initWithStopId:(NSString *)stop_id
{
    if (stop_id == nil) {
        return nil;
    }
    
    if (self = [super init]) {
        GTFSDatabase *db = nil;
        if ((db = [GTFSDatabase open]) == nil) {
            return nil;
        }
    
        NSString *query = @"select stop_id, stop_name, stop_lat, stop_lon, routes FROM stops WHERE stop_id=?";
    
        FMResultSet *rs = [db executeQuery:query withArgumentsInArray:@[stop_id]];
        
        if ([rs next]) {
            self.stopId = [rs objectForColumnName:@"stop_id"];
            self.stopName = [rs objectForColumnName:@"stop_name"];
            
            double latitude = [[rs objectForColumnName:@"stop_lat"] doubleValue];
            double longitude = [[rs objectForColumnName:@"stop_lon"] doubleValue];
            self.location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            
            self.routesString = [rs objectForColumnName:@"routes"];
            
            self.milesAway = 0.0;
            
        } else {
            [rs close];
            [db close];
            return nil;
        }

        [rs close];
        [db close];
    }
    return self;
}

/*
 Returns YES if this stop is one of the user's favorite stops.
 */
- (BOOL) isFavoriteStop {
    NSArray *favoriteStops = [MStop getFavoriteStops];
    for (MStop *stop in favoriteStops) {
        if ([stop.stopId isEqualToString:self.stopId]) {
            return YES;
        }
    }
    return NO;
}

/*
 Return an array of MStop objects representing the user's favorite Marguerite stops.
 */
+ (NSArray *) getFavoriteStops
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"favoriteStops"];
    if (data) {
        NSArray *favoriteStops = (NSArray *) [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return favoriteStops;
    } else {
        return nil;
    }
}

/*
 Set the user's favorite Marguerite stops using the given array.
 */
+ (void) setFavoriteStops:(NSArray *)stops
{
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:stops];
    [defaults setObject:data forKey:@"favoriteStops"];
    [defaults synchronize];
}

/* 
 Return an array of MStop objects representing all Marguerite stops.
 */
+ (NSArray *) getAllStops
{
    GTFSDatabase *db = nil;
    if ((db = [GTFSDatabase open]) == nil) {
        return nil;
    }
    
    NSString *query = @"select stop_id, stop_name, stop_lat, stop_lon, routes FROM stops";
    
    FMResultSet *rs = [db executeQuery:query];
    
    NSMutableArray *stops = [[NSMutableArray alloc] init];
    while ([rs next]) {
        MStop *stop = [[MStop alloc] init];
        stop.stopId = [rs objectForColumnName:@"stop_id"];
        stop.stopName = [rs objectForColumnName:@"stop_name"];
        
        double latitude = [[rs objectForColumnName:@"stop_lat"] doubleValue];
        double longitude = [[rs objectForColumnName:@"stop_lon"] doubleValue];
        stop.location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        
        stop.routesString = [rs objectForColumnName:@"routes"];
        
        stop.milesAway = 0.0;
        [stops addObject:stop];
    }

    [rs close];
    [db close];
    return stops;
}

/*
 Return an NSArray of the 'numStops' closest stops to 'location'.
 Also updates the milesAway field of each stop.
 */
+ (NSArray *)getClosestStops:(int)numStops withLocation:(CLLocation *)location
{
    NSArray *allStops = [self getAllStops];
    numStops = MIN(numStops, [allStops count]);
    
    NSArray *stopsSortedByDistance;
    stopsSortedByDistance = [allStops sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        MStop *first = (MStop *) a;
        MStop *second = (MStop *) b;
        
        first.milesAway = [first.location distanceFromLocation:location] * METERS_IN_A_MILE;
        second.milesAway = [second.location distanceFromLocation:location] * METERS_IN_A_MILE;
        
        if (first.milesAway < second.milesAway) {
            return NSOrderedAscending;
        } else if (first.milesAway > second.milesAway) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    return [stopsSortedByDistance subarrayWithRange:NSMakeRange(0, numStops)];
}


- (void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.stopId forKey:@"stopId"];
}

- (id) initWithCoder:(NSCoder *)decoder
{
    return [self initWithStopId:[decoder decodeObjectForKey:@"stopId"]];
}

@end
