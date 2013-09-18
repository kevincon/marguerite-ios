//
//  StopViewController.m
//  marguerite
//
//  Created by Kevin Conley on 7/10/13.
//  Copyright (c) 2013 Stanford Devs. All rights reserved.
//

#import "StopViewController.h"
#import "FMDatabase.h"
#import "GTFSDatabase.h"
#import "MStopTime.h"
#import "MUtil.h"

#define ADD_FAVORITE_STOP_SECTION_INDEX 0

#define BUSES_SECTION_INDEX             1
#define BUSES_SECTION_HEADER            @"Next Buses"

#define STOPS_NUMBER_OF_SECTIONS        2

@interface StopViewController ()

@end

@implementation StopViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
	self.title = _stop.stopName;
    _nextBuses = [self getNextBuses];
    
    // Initialize the "pull down to refresh" control
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self
                action:@selector(refreshView:)
      forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    [self.tableView reloadData];
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"Viewed next shuttles for stop %@.", self.stop.stopName]];
}

- (void) addStopToFavorites
{
    NSMutableArray *favoriteStops = [[NSMutableArray alloc] initWithArray:[MStop getFavoriteStops]];
    [favoriteStops addObject:self.stop];
    [MStop setFavoriteStops:favoriteStops];
    
    self.isFavoriteStop = YES;
    [self.tableView reloadData];
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"Added favorite stop %@.", self.stop.stopName]];
}

- (void) removeStopFromFavorites
{
    NSMutableArray *favoriteStops = [[NSMutableArray alloc] initWithArray:[MStop getFavoriteStops]];
    NSMutableArray *newFavoriteStops = [[NSMutableArray alloc] init];
    for (MStop *stop in favoriteStops) {
        if ([stop.stopId isEqualToString:self.stop.stopId] == NO) {
            [newFavoriteStops addObject:stop];
        }
    }
    [MStop setFavoriteStops:newFavoriteStops];
    
    self.isFavoriteStop = NO;
    [self.tableView reloadData];
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"Removed favorite stop %@.", self.stop.stopName]];
}

/*
 Return an array of up to 8 MStopTime's with information about the next arriving buses.
 */
- (NSArray *) getNextBuses
{
    GTFSDatabase *db = nil;
    if ((db = [GTFSDatabase open]) == nil) {
        return nil;
    }
    
    // Create a yyyy-MM-dd date string for today's date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *todaysDate = [dateFormat stringFromDate:[NSDate date]];
    
    // Create a HH:mm:ss time string for the current time
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm:ss"];
    NSString *timeString = [timeFormat stringFromDate:[NSDate date]];
    
    // Note: we must manually insert the routes string into the query string; it doesn't work if you try to do it with executeQuery
    NSString *departureTimesQuery = [NSString stringWithFormat:@"SELECT stop_times.departure_time, routes.route_long_name, routes.route_color, routes.route_text_color, trips.trip_id FROM routes, trips, calendar_dates, stop_times WHERE trips.service_id=calendar_dates.service_id AND calendar_dates.date=? AND stop_times.pickup_type=0 AND stop_times.trip_id=trips.trip_id AND routes.route_id=trips.route_id AND stop_times.stop_id=? AND trips.route_id IN (%@) AND time(stop_times.departure_time) > time(\'%@\') GROUP BY stop_times.departure_time, routes.route_long_name ORDER BY time(stop_times.departure_time)", self.stop.routesString, timeString];
    
    FMResultSet *departureTimesRS = [db executeQuery:departureTimesQuery withArgumentsInArray:@[todaysDate, self.stop.stopId]];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSMutableArray *todaysBuses = [[NSMutableArray alloc] init];
    while([departureTimesRS next]) {
        MStopTime *bus = [[MStopTime alloc] init];
        bus.routeLongName = [departureTimesRS objectForColumnName:@"route_long_name"];
        bus.tripId = [departureTimesRS objectForColumnName:@"trip_id"];
        bus.routeColor = [MUtil colorFromHexString:[departureTimesRS objectForColumnName:@"route_color"]];
        bus.routeTextColor = [MUtil colorFromHexString:[departureTimesRS objectForColumnName:@"route_text_color"]];

        NSString *departure_time = [departureTimesRS objectForColumnName:@"departure_time"];
        
        // Some departure times have 24 as the hour, so we need to change that to 00
        NSMutableArray *timeTokens = [[NSMutableArray alloc] initWithArray:[departure_time componentsSeparatedByString:@":"]];
        if ([timeTokens[0] isEqualToString:@"24"]) {
            timeTokens[0] = @"00";
            departure_time = [timeTokens componentsJoinedByString:@":"];
        }
        
        bus.departureTime = [timeFormat dateFromString:departure_time];
        
        NSDateComponents *components = [calendar components:(NSHourCalendarUnit) fromDate:bus.departureTime];
        NSInteger hour = [components hour];
        if (hour == 24) {
            bus.departureTime = [bus.departureTime dateByAddingTimeInterval:86400];
        }
        
        [todaysBuses addObject:bus];
    }
    [departureTimesRS close];
    
    // Return up to 8 of the next arriving buses
    NSArray *buses = [todaysBuses subarrayWithRange:NSMakeRange(0, MIN(8, [todaysBuses count]))];
    
    [db close];
    
    return buses;
}

#pragma mark - Table Refresh

-(void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
    _nextBuses = [self getNextBuses];
    [self.tableView reloadData];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                             [formatter stringFromDate:[NSDate date]]];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    [refresh endRefreshing];
    [TestFlight passCheckpoint:@"Refreshed buses for a stop."];
}

#pragma mark - Table

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier;
    if (indexPath.section == ADD_FAVORITE_STOP_SECTION_INDEX) {
        cellIdentifier = @"AddFavoriteStopCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (self.isFavoriteStop == YES) {
            cell.textLabel.text = @"Remove Favorite Stop";
        } else {
            cell.textLabel.text = @"Add Favorite Stop";
        }
        return cell;
    } else if (indexPath.section == BUSES_SECTION_INDEX) {
        if ([_nextBuses count] == 0) {
            return nil;
        }
        
        cellIdentifier = @"BusCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        NSDateFormatter *twelveHourFormat = [[NSDateFormatter alloc] init];
        [twelveHourFormat setDateFormat:@"h:mm a"];
        
        MStopTime *bus = [_nextBuses objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [twelveHourFormat stringFromDate:bus.departureTime];
        cell.detailTextLabel.text = bus.routeLongName;
        cell.detailTextLabel.textColor = bus.routeColor;
        
        return cell;
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case ADD_FAVORITE_STOP_SECTION_INDEX:
            return 1;
        case BUSES_SECTION_INDEX:
            return [_nextBuses count];
        default:
            return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return STOPS_NUMBER_OF_SECTIONS;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case ADD_FAVORITE_STOP_SECTION_INDEX:
            return nil;
        case BUSES_SECTION_INDEX:
            return BUSES_SECTION_HEADER;
        default:
            return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case BUSES_SECTION_INDEX:
            if ([_nextBuses count] == 0) {
                return @"Today's service complete.";
            } else {
                return nil;
            }
        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case ADD_FAVORITE_STOP_SECTION_INDEX:
            if (self.isFavoriteStop) {
                [self removeStopFromFavorites];
            } else {
                [self addStopToFavorites];
            }
            [tableView cellForRowAtIndexPath:indexPath].selected = NO;
            break;
    }
}

@end
