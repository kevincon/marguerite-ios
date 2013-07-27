//
//  MRoute.m
//  marguerite
//
//  Created by Kevin Conley on 7/20/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "MRoute.h"
#import "GTFSDatabase.h"
#import "MUtil.h"

@implementation MRoute

/*
 Return an MRoute object by looking up the route in the GTFS database. Returns nil if the route 
 does not exist.
 */
- (id) initWithRouteIdString:(NSString *) route_id
{
    if (route_id == nil) {
        return nil;
    }
    
    if ((self = [super init])) {
        GTFSDatabase *db = nil;
        if ((db = [GTFSDatabase open]) == nil) {
            return nil;
        }
        
        NSString *routesQuery = @"SELECT route_long_name, route_short_name, route_url, route_color, route_text_color FROM routes WHERE route_id=?";
        
        FMResultSet *routesRS = [db executeQuery:routesQuery withArgumentsInArray:@[route_id]];
        if ([routesRS next]) {
            self.routeId = route_id;
            self.routeLongName = [routesRS objectForColumnName:@"route_long_name"];
            self.routeShortName = [routesRS objectForColumnName:@"route_short_name"];
            self.routeUrl = [[NSURL alloc] initWithString:[routesRS objectForColumnName:@"route_url"]];
            [self setColorUsingHexString:[routesRS objectForColumnName:@"route_color"]];
            [self setTextColorUsingHexString:[routesRS objectForColumnName:@"route_text_color"]];
        } else {
            [routesRS close];
            [db close];
            return nil;
        }
        
        [routesRS close];
        [db close];
    }
    return self;
}

/*
 Set the UIColor for the route's color using the hex string.
 */
- (void) setColorUsingHexString:(NSString *) hexString
{
    self.routeColor = [MUtil colorFromHexString:hexString];
}

/*
 Set the UIColor for the route's text color using a hex string.
 */
- (void) setTextColorUsingHexString:(NSString *) hexString
{
    self.routeTextColor = [MUtil colorFromHexString:hexString];
}

@end
