//
//  MSchedule.m
//  marguerite
//
//  Created by Kevin Conley on 9/18/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "MSchedule.h"
#import "MRoute.h"
#import "MStop.h"
#import "MTrip.h"
#import "GTFSDatabase.h"

@implementation MSchedule

- (id) initWithRoute:(MRoute *)given_route
{
    if (given_route == nil) {
        return nil;
    } else {
        _route = given_route;
    }
    
    GTFSDatabase *db = nil;
    if ((db = [GTFSDatabase open]) == nil) {
        return nil;
    }
    
    // Create a yyyy-MM-dd date string for today's date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *todaysDate = [dateFormat stringFromDate:[NSDate date]];
    
    // First SQLite query: get the stops for the trip with the most stops for today
    // (these will be the stops we use for the column headers of the schedule table)
    
    NSString *stopsQuery = @"SELECT stop_times.stop_id FROM (SELECT stop_times.trip_id, count(*) FROM stop_times, routes, trips, calendar_dates WHERE calendar_dates.date=? AND routes.route_id=? AND trips.route_id=routes.route_id AND stop_times.trip_id=trips.trip_id AND calendar_dates.service_id=trips.service_id GROUP BY stop_times.trip_id ORDER BY count(*) DESC LIMIT 1) AS most_stops, stop_times WHERE stop_times.trip_id=most_stops.trip_id AND stop_times.pickup_type=0 ORDER BY stop_times.stop_sequence";
    
    FMResultSet *stopsRS = [db executeQuery:stopsQuery withArgumentsInArray:@[todaysDate, _route.routeId]];
    NSMutableArray *all_stops = [[NSMutableArray alloc] init];
    while ([stopsRS next]) {
        NSString *stopId = [stopsRS objectForColumnName:@"stop_id"];
        MStop *stop = [[MStop alloc] initWithStopId:stopId];
        if (stop) {
            [all_stops addObject:stop];
        }
    }
    [stopsRS close];
    
    // Next SQLite query: get the trip_ids for all trips for today
    // (these will form the cells for the schedule table, where each row is a different trip)
    NSString *tripsQuery = @"SELECT stop_times.trip_id FROM stop_times, routes, trips, calendar_dates WHERE calendar_dates.date=? AND routes.route_id=? AND trips.route_id=routes.route_id AND stop_times.trip_id=trips.trip_id AND calendar_dates.service_id=trips.service_id AND stop_times.stop_sequence=1 AND stop_times.pickup_type=0 GROUP BY stop_times.trip_id ORDER BY stop_times.departure_time";
    
    FMResultSet *tripsRS = [db executeQuery:tripsQuery withArgumentsInArray:@[todaysDate, _route.routeId]];
    NSMutableArray *all_trips = [[NSMutableArray alloc] init];
    while ([tripsRS next]) {
        NSString *tripId = [tripsRS objectForColumnName:@"trip_id"];
        MTrip *trip = [[MTrip alloc] initWithTripId:tripId];
        if (trip) {
            [all_trips addObject:trip];
        }
    }
    [tripsRS close];
    
    [db close];
    
    if ((self = [super init])) {
        _stops = all_stops;
        _trips = all_trips;
    }
    return self;
}


@end
