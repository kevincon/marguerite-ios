//
//  ScheduleViewController.m
//  marguerite
//
//  Created by Kevin Conley on 9/18/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "ScheduleViewController.h"
#import "MDSpreadViewClasses.h"
#import "MSchedule.h"
#import "MTrip.h"
#import "MStop.h"
#import "MStopTime.h"

@interface ScheduleViewController ()

@end

@implementation ScheduleViewController
@synthesize spreadView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	[spreadView reloadData];
    self.title = _schedule.route.routeLongName;
}

# pragma mark - MDSpreadView data source
- (NSInteger)numberOfColumnSectionsInSpreadView:(MDSpreadView *)aSpreadView
{
    return 1;
}

- (NSInteger)numberOfRowSectionsInSpreadView:(MDSpreadView *)aSpreadView
{
    return 1;
}

- (NSInteger)spreadView:(MDSpreadView *)aSpreadView numberOfColumnsInSection:(NSInteger)section
{
    return [_schedule.stops count];
}

- (NSInteger)spreadView:(MDSpreadView *)aSpreadView numberOfRowsInSection:(NSInteger)section
{
    return [_schedule.trips count];
}

#pragma mark - MDSpreadView Heights
// Comment these out to use normal values (see MDSpreadView.h)
- (CGFloat)spreadView:(MDSpreadView *)aSpreadView heightForRowAtIndexPath:(MDIndexPath *)indexPath
{
    return 25;
}

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView heightForRowHeaderInSection:(NSInteger)rowSection
{
    //    if (rowSection == 2) return 0; // uncomment to hide this header!
    return 22+rowSection;
}

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView widthForColumnAtIndexPath:(MDIndexPath *)indexPath
{
    MStop *columnHeaderStop = [_schedule.stops objectAtIndex:indexPath.column];
    NSString *columnHeader = columnHeaderStop.stopName;
    CGSize headerBoundingBox = [columnHeader sizeWithFont:[UIFont boldSystemFontOfSize:23]];
    
    MTrip *firstTrip = [_schedule.trips objectAtIndex:0];
    MStopTime *firstStopTime = [firstTrip.stopTimes objectAtIndex:0];
    NSDateFormatter *twelveHourFormat = [[NSDateFormatter alloc] init];
    [twelveHourFormat setDateFormat:@"h:mm a"];
    NSString *timeString = [twelveHourFormat stringFromDate:firstStopTime.departureTime];
    CGSize timeBoundingBox = [timeString sizeWithFont:[UIFont boldSystemFontOfSize:26]];
    
    return MAX(headerBoundingBox.width, timeBoundingBox.width);
    //return 220+indexPath.column*5;
}

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView widthForColumnHeaderInSection:(NSInteger)columnSection
{
    return 0;
}

#pragma mark - MDSpreadView Cells
- (id)spreadView:(MDSpreadView *)aSpreadView objectValueForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath
{
    MStop *columnStop = [_schedule.stops objectAtIndex:columnPath.column];
    
    MTrip *trip = [_schedule.trips objectAtIndex:rowPath.row];
    
    for (MStopTime *stopTime in trip.stopTimes) {
        if ([columnStop.stopId isEqualToString:stopTime.stopId]) {
            NSDateFormatter *twelveHourFormat = [[NSDateFormatter alloc] init];
            [twelveHourFormat setDateFormat:@"h:mm a"];
            return [twelveHourFormat stringFromDate:stopTime.departureTime];
        }
    }
    
    return @"---";
}

- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath
{
    MStop *stop = [_schedule.stops objectAtIndex:columnPath.column];
    return stop.stopName;
}

- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection
{
    return @"";
}

//- (void)spreadView:(MDSpreadView *)aSpreadView didSelectCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath
//{
//    [spreadView deselectCellForRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath animated:YES];
//    NSLog(@"Selected %@ x %@", rowPath, columnPath);
//}
//

- (MDSpreadViewSelection *)spreadView:(MDSpreadView *)aSpreadView willSelectCellForSelection:(MDSpreadViewSelection *)selection
{
    return [MDSpreadViewSelection selectionWithRow:selection.rowPath column:selection.columnPath mode:MDSpreadViewSelectionModeNone];
}

@end