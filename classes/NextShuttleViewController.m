//
//  FirstViewController.m
//  marguerite
//
//  Created by Kevin Conley on 6/24/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "NextShuttleViewController.h"
#import "StopViewController.h"
#import "MStop.h"

#define FEET_IN_MILES 5280

#define NEARBY_STOPS_SECTION_INDEX      0
#define NEARBY_STOPS_SECTION_HEADER     @"Nearby Stops"

#define FAVORITE_STOPS_SECTION_INDEX    1
#define FAVORITE_STOPS_SECTION_HEADER   @"Favorite Stops"

#define ALL_STOPS_SECTION_INDEX         2
#define ALL_STOPS_SECTION_HEADER        @"All Stops"

#define STOPS_NUMBER_OF_SECTIONS        3

@interface NextShuttleViewController ()
@end

@implementation NextShuttleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    CLController = [[CoreLocationController alloc] init];
	CLController.delegate = self;

    // Initialize the "pull down to refresh" control
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self
                action:@selector(refreshView:)
                forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    allStops = [MStop getAllStops];
    
    // Sort the stops alphabetically by name
    allStops = [allStops sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        MStop *firstStop = (MStop *) a;
        MStop *secondStop = (MStop *) b;
        
        return [firstStop.stopName caseInsensitiveCompare:secondStop.stopName];
    }];
    
    [self updateLocation];
    [self.tableView reloadData];

    [TestFlight passCheckpoint:@"Visited Next Shuttle tab."];
}

- (void) viewWillAppear:(BOOL)animated
{
    favoriteStops = [MStop getFavoriteStops];
    [self updateLocation];
    [self.tableView reloadData];
}

#pragma mark - Table Refresh

-(void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];

    [self updateLocation];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                                    [formatter stringFromDate:[NSDate date]]];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    [refresh endRefreshing];
    [TestFlight passCheckpoint:@"Refreshed nearest stops."];
}

#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return STOPS_NUMBER_OF_SECTIONS;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // If the user is searching, return the number of results
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    }
        
    // Number of rows is the number of stops in the region for the specified section.
    switch (section) {
        case NEARBY_STOPS_SECTION_INDEX:
            return [closestStops count];
        case FAVORITE_STOPS_SECTION_INDEX:
            return [favoriteStops count];
        case ALL_STOPS_SECTION_INDEX:
            return [allStops count];
        default:
            return 0;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // If this is a search, don't display any section headers
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    
    switch (section) {
        case NEARBY_STOPS_SECTION_INDEX:
            return NEARBY_STOPS_SECTION_HEADER;
        case FAVORITE_STOPS_SECTION_INDEX:
            return FAVORITE_STOPS_SECTION_HEADER;
        case ALL_STOPS_SECTION_INDEX:
            return ALL_STOPS_SECTION_HEADER;
        default:
            return nil;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier;
    UITableViewCell *cell;
    MStop *stop;
    
    // If this is a search, only show search results (no nearby stops or favorites)
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cellIdentifier = @"AllStopCell";
        cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
             cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        stop = [searchResults objectAtIndex:indexPath.row];
        
        cell.textLabel.text = stop.stopName;
        
        return cell;
    }
    
    switch (indexPath.section) {
        case NEARBY_STOPS_SECTION_INDEX: {
            cellIdentifier = @"NearbyStopCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            stop = [closestStops objectAtIndex:indexPath.row];
            
            cell.textLabel.text = stop.stopName;
            
            int distanceInFeet = stop.milesAway * FEET_IN_MILES;
            NSString *distanceString;
            if (stop.milesAway < 1.0) {
                distanceString = [[NSString alloc] initWithFormat:@"%d feet", distanceInFeet];
            } else {
                distanceString = [[NSString alloc] initWithFormat:@"%.2f miles", stop.milesAway];
            }
            cell.detailTextLabel.text = distanceString;
            return cell;
        }
        case FAVORITE_STOPS_SECTION_INDEX: {
            cellIdentifier = @"FavoriteStopCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            stop = [favoriteStops objectAtIndex:indexPath.row];
            
            cell.textLabel.text = stop.stopName;
            return cell;
        }
        case ALL_STOPS_SECTION_INDEX: {
            cellIdentifier = @"AllStopCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            stop = [allStops objectAtIndex:indexPath.row];
            
            cell.textLabel.text = stop.stopName;
            
            return cell;
        }
    }
    return nil;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"SelectedNearbyStopSegue"]) {
		StopViewController *stopViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)sender];
        stopViewController.stop = [closestStops objectAtIndex:indexPath.row];
        stopViewController.isFavoriteStop = [stopViewController.stop isFavoriteStop];
	} else if ([segue.identifier isEqualToString:@"SelectedFavoriteStopSegue"] || [segue.identifier isEqualToString:@"SelectedAllStopSegue"]) {
        StopViewController *stopViewController = segue.destinationViewController;
        
        NSIndexPath *indexPath = nil;
        
        // Make sure to access the right tableView based on whether the user is searching or not
        if ([self.searchDisplayController isActive]) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            stopViewController.stop = [searchResults objectAtIndex:indexPath.row];
        } else {
            indexPath = [self.tableView indexPathForCell:(UITableViewCell*)sender];
            if ([segue.identifier isEqualToString:@"SelectedFavoriteStopSegue"]) {
                stopViewController.stop = [favoriteStops objectAtIndex:indexPath.row];
            } else if ([segue.identifier isEqualToString:@"SelectedAllStopSegue"]) {
                stopViewController.stop = [allStops objectAtIndex:indexPath.row];
            }
        }
        stopViewController.isFavoriteStop = [stopViewController.stop isFavoriteStop];
    }
}

#pragma mark - Searching

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"stopName contains[cd] %@ OR stopId == %@",
                                    searchText, searchText];
    
    searchResults = [allStops filteredArrayUsingPredicate:resultPredicate];
}

#pragma mark - GPS Location

-(void)updateLocation {
    CLController.locMgr.desiredAccuracy = kCLLocationAccuracyBest;
    [CLController.locMgr startUpdatingLocation];
}

- (void)locationUpdate:(CLLocation *)location {
    closestStops = [MStop getClosestStops:3 withLocation:location];

    [[CLController locMgr] stopUpdatingLocation];
    
    [self.tableView reloadData];
}

- (void)locationError:(NSError *)error {
	NSLog(@"didFailWithError: %@", error);
//    UIAlertView *errorAlert = [[UIAlertView alloc]
//                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [errorAlert show];
    [TestFlight passCheckpoint:@"Failed to get user's GPS location."];
}

@end
