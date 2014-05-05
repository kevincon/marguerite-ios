//
//  Util.m
//  GTFSImporter
//
//  Created by Vashishtha Jogi on 9/7/11.
//  Copyright 2011 Vashishtha Jogi. All rights reserved.
//

#import "Util.h"
#import "GTFSDatabase.h"
#import "CSVImporter.h"

#define kEarthRadius     6378135    //in meters

@implementation Util

/*
 Convert meters to miles.
 */
+ (double) metersToMiles:(double)meters
{
    return meters * 0.00062137;
}

/*Compute approximate distance between two points in miles. Assumes the
 Earth is a sphere.
 # TODO: change to ellipsoid approximation, such as
 # http://www.codeguru.com/Cpp/Cpp/algorithms/article.php/c5115/
 */
+ (double) ApproximateDistanceWithLat1:(double)lat1 withLon1:(double)lon1 withLat2:(double)lat2 withLon2:(double)lon2
{
    lat1 = lat1 * M_PI/180;
    lon1 = lon1 * M_PI/180;
    lat2 = lat2 * M_PI/180;
    lon2 = lon2 * M_PI/180;
    
    double dlat = sin(0.5 * (lat2 - lat1));
    double dlng = sin(0.5 * (lon2 - lon1));
    double x = dlat * dlat + dlng * dlng * cos(lat1) * cos(lat2);
    
    return [Util metersToMiles:(kEarthRadius * (2 * atan2(sqrt(x), sqrt(MAX(0.0, 1.0 - x)))))];
}

//Compute approximate distance between two stops in miles. Assumes the
//Earth is a sphere.

+ (double) ApproximateDistanceBetweenStop1:(CLLocation *)stop1 stop2:(CLLocation *)stop2
{
    return [Util ApproximateDistanceWithLat1:stop1.coordinate.latitude withLon1:stop1.coordinate.longitude
                                    withLat2:stop2.coordinate.latitude withLon2:stop2.coordinate.longitude];
}

/*
 Convert HHH:MM:SS into seconds since midnight.
 
 For example "01:02:03" returns 3723. The leading zero of the hours may be
 omitted. HH may be more than 23 if the time is on the following day.
 */

+ (NSNumber *) TimeToSecondsSinceMidnight:(NSString *)time
{
    NSArray *timeArray = [time componentsSeparatedByString:@":"];
    return @([timeArray[0] intValue] * 3600 + [timeArray[1] intValue] * 60 + [timeArray[2] intValue]);;
}

// Formats an int number of seconds past midnight into a string as "HH:MM:SS".

+ (NSString *) FormatSecondsSinceMidnight:(NSNumber *)seconds
{
    int s = [seconds intValue];
    return [NSString stringWithFormat:@"%02d:%02d:%02d", s / 3600, (s / 60) % 60, s % 60];
}

+ (NSString *) getDayFromDate:(NSDate *)date
{
    // setting units we would like to use in future
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit;
    // creating NSCalendar object
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    // extracting components from date
    NSDateComponents *components = [calendar components:units fromDate:date];
    
    
    switch ([components weekday]) {
        case 1:
            return @"sunday";
            break;
        case 2:
            return @"monday";
            break;
        case 3:
            return @"tuesday";
            break;
        case 4:
            return @"wednesday";
            break;
        case 5:
            return @"thursday";
            break;
        case 6:
            return @"friday";
            break;
        case 7:
            return @"saturday";
            break;
        default:
            return @"";
            break;
    }
}

//Converts NSDate to specified format, Default yyyy-MM-dd if nil is passed for format
+ (NSString *) getDateStringFromDate:(NSDate *)date withFormat:(NSString *)format
{
    NSDateFormatter *sDateFormatter = [[NSDateFormatter alloc] init];
    if (format==nil)
        [sDateFormatter setDateFormat:@"yyyy-MM-dd"];
    else
        [sDateFormatter setDateFormat:format];
    
    return [sDateFormatter stringFromDate:date];
    
}

//Converts NSDate to specified format, Default hh:mm:ss if nil is passed for format
+ (NSString *) getTimeStringFromDate:(NSDate *)date withFormat:(NSString *)format
{
    NSDateFormatter *sDateFormatter = [[NSDateFormatter alloc] init];
    if (format==nil)
        [sDateFormatter setDateFormat:@"HH:mm:ss"];
    else
        [sDateFormatter setDateFormat:format];
    
    return [sDateFormatter stringFromDate:date];
    
}


@end
