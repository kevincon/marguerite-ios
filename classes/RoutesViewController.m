//
//  SchedulesViewController.m
//  marguerite
//
//  Created by Kevin Conley on 9/18/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "RoutesViewController.h"
#import "ScheduleViewController.h"
#import "MRoute.h"

@interface RoutesViewController ()

@end

@implementation RoutesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    allRoutes = [MRoute getAllRoutes];
    
    // Sort the routes alphabetically by name
    allRoutes = [allRoutes sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        MRoute *firstRoute = (MRoute *) a;
        MRoute *secondRoute = (MRoute *) b;
        
        return [firstRoute.routeLongName caseInsensitiveCompare:secondRoute.routeLongName];
    }];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [allRoutes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"AllRoutesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    MRoute *route = [allRoutes objectAtIndex:indexPath.row];
    
    cell.textLabel.text = route.routeLongName;
    cell.textLabel.textColor = route.routeTextColor;
    cell.contentView.backgroundColor = route.routeColor;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = cell.contentView.backgroundColor;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ScheduleViewController *scheduleViewController = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)sender];
    scheduleViewController.schedule = [[MSchedule alloc] initWithRoute:[allRoutes objectAtIndex:indexPath.row]];
}

@end