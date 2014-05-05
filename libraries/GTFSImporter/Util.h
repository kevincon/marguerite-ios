//
//  Util.h
//  GTFSImporter
//
//  Created by Vashishtha Jogi on 9/7/11.
//  Copyright 2011 Vashishtha Jogi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Util : NSObject

+ (double) ApproximateDistanceWithLat1:(double)lat1 withLon1:(double)lon1 withLat2:(double)lat2 withLon2:(double)lon2;
+ (double) ApproximateDistanceBetweenStop1:(CLLocation *)stop1 stop2:(CLLocation *)stop2;
+ (NSNumber *) TimeToSecondsSinceMidnight:(NSString *)time;
+ (NSString *) FormatSecondsSinceMidnight:(NSNumber *)seconds;
+ (NSString *) getDayFromDate:(NSDate *)date;
+ (NSString *) getDateStringFromDate:(NSDate *)date withFormat:(NSString *)format;
+ (NSString *) getTimeStringFromDate:(NSDate *)date withFormat:(NSString *)format;


@end
