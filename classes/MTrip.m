//
//  MTrip.m
//  marguerite
//
//  Created by Kevin Conley on 9/18/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "MTrip.h"
#import "MStopTime.h"
#import "GTFSDatabase.h"

@implementation MTrip

- (id) initWithTripId:(NSString *)trip_id
{
    if (trip_id == nil) {
        return nil;
    }
    
    GTFSDatabase *db = nil;
    if ((db = [GTFSDatabase open]) == nil) {
        return nil;
    }
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm:ss"];
    
    NSString *stopTimesQuery = @"SELECT stop_times.* FROM stop_times WHERE stop_times.trip_id=?";
    
    FMResultSet *stopTimesRS = [db executeQuery:stopTimesQuery withArgumentsInArray:@[trip_id]];
    NSMutableArray *stop_times = [[NSMutableArray alloc] init];
    while ([stopTimesRS next]) {
        MStopTime *stopTime = [[MStopTime alloc] init];
        
        NSString *departure_time = [stopTimesRS objectForColumnName:@"departure_time"];
        stopTime.departureTime = [timeFormat dateFromString:departure_time];
        stopTime.stopId = [stopTimesRS objectForColumnName:@"stop_id"];
        //stopTime.tripId = [stopTimesRS objectForColumnName:@"trip_id"];
        
        if (stopTime) {
            [stop_times addObject:stopTime];
        }
    }
    [stopTimesRS close];
    
    [db close];
    
    if ((self = [super init])) {
        _stopTimes = stop_times;
    }
    return self;
}

@end