//
//  CSVImporter.m
//  San Jose Transit GTFS
//
//  Created by Vashishtha Jogi on 8/27/11.
//  Copyright 2011 Vashishtha Jogi Inc. All rights reserved.
//

#import "GTFSImporter.h"
#import "FMDatabase.h"
#import "CSVParser.h"
#import "GTFSAgency.h"
#import "GTFSFareAttributes.h"
#import "GTFSFareRules.h"
#import "GTFSCalendar.h"
#import "GTFSCalendarDate.h"
#import "GTFSRoute.h"
#import "GTFSShape.h"
#import "GTFSStop.h"
#import "GTFSTrip.h"
#import "GTFSStopTime.h"
#import "Marguerite-Swift.h"
#import "GTFSUnarchiver.h"

@interface GTFSImporter()


@end

@implementation GTFSImporter

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSString *)parseForFile:(NSString *)file
{
    NSError *error = nil;
    //NSString* unzippedDirPath = [GTFSUnarchiver fullPathToDownloadedTransitUnzipDir];
    NSString *inputPath = [[NSBundle mainBundle] pathForResource:file ofType:@"txt"];
    //NSString *inputPath = [unzippedDirPath stringByAppendingPathComponent:file];
    //inputPath = [inputPath stringByAppendingPathExtension:@"txt"];
	NSString *csvString = [NSString stringWithContentsOfFile:inputPath encoding:NSUTF8StringEncoding error:&error];
    
	if (!csvString)
	{
		NSLog(@"Couldn't read file at path %s\n. Error: %s", [inputPath UTF8String], [[error localizedDescription] ? [error localizedDescription] : [error description] UTF8String]);
	}
    return csvString;
}

- (int) addCalendar
{
	NSDate *startDate = [NSDate date];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[GTFSDatabase autoUpdateDatabasePath]];
    [db setShouldCacheStatements:YES];
    if (![db open]) {
        NSLog(@"Could not open db.");
        //[db release];
        return 1;
    }
	
    NSString *csvString = [self parseForFile:@"calendar"];
    
    GTFSCalendar *cal = [[GTFSCalendar alloc] initWithDB:db];
    
	CSVParser *parser =
    [[CSVParser alloc]
      initWithString:csvString
      separator:@","
      hasHeader:YES
      fieldNames:nil];
    
    [cal cleanupAndCreate];
    [db beginTransaction];
    [parser parseRowsForReceiver:cal selector:@selector(receiveRecord:)];
    [db commit];
    
	NSDate *endDate = [NSDate date];
    
	NSLog(@"Calendar entries successfully imported in %f seconds.", [endDate timeIntervalSinceDate:startDate]);
    
    [db close];
	
    return 0;
}

- (int) addCalendarDate
{
	NSDate *startDate = [NSDate date];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[GTFSDatabase autoUpdateDatabasePath]];
    [db setShouldCacheStatements:YES];
    if (![db open]) {
        NSLog(@"Could not open db.");
        //[db release];
        return 1;
    }
	
    NSString *csvString = [self parseForFile:@"calendar_dates"];
    
    GTFSCalendarDate *calDate = [[GTFSCalendarDate alloc] initWithDB:db];
    
	CSVParser *parser =
    [[CSVParser alloc]
     initWithString:csvString
     separator:@","
     hasHeader:YES
     fieldNames:nil];
    
    [calDate cleanupAndCreate];
    [db beginTransaction];
    [parser parseRowsForReceiver:calDate selector:@selector(receiveRecord:)];
    [db commit];
    
	NSDate *endDate = [NSDate date];
    
	NSLog(@"Calendar Dates entries successfully imported in %f seconds.", [endDate timeIntervalSinceDate:startDate]);
    
    [db close];
	
    return 0;
}


- (int) addAgency
{	
	NSDate *startDate = [NSDate date];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[GTFSDatabase autoUpdateDatabasePath]];
    
    [db setShouldCacheStatements:YES];
    if (![db open]) {
        NSLog(@"Could not open db.");
        //[db release];
        return 1;
    }
	
    NSString *csvString = [self parseForFile:@"agency"];
    
    GTFSAgency *agency = [[GTFSAgency alloc] initWithDB:db];
    
	CSVParser *parser =
    [[CSVParser alloc]
      initWithString:csvString
      separator:@","
      hasHeader:YES
      fieldNames:nil];
    
    [agency cleanupAndCreate];
    [db beginTransaction];
    [parser parseRowsForReceiver:agency selector:@selector(receiveRecord:)];
    [db commit];
    
	NSDate *endDate = [NSDate date];
    
	NSLog(@"Agency entries successfully imported in %f seconds.", [endDate timeIntervalSinceDate:startDate]);
    
    [db close];
	
    return 0;
}

- (int) addFareAttributes
{	
	NSDate *startDate = [NSDate date];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[GTFSDatabase autoUpdateDatabasePath]];

    [db setShouldCacheStatements:YES];
    if (![db open]) {
        NSLog(@"Could not open db.");
        //[db release];
        return 1;
    }
	
    NSString *csvString = [self parseForFile:@"fare_attributes"];
    
    GTFSFareAttributes *fareAttributes = [[GTFSFareAttributes alloc] initWithDB:db];
    
	CSVParser *parser =
    [[CSVParser alloc]
      initWithString:csvString
      separator:@","
      hasHeader:YES
      fieldNames:nil];
    
    [fareAttributes cleanupAndCreate];
    [db beginTransaction];
    [parser parseRowsForReceiver:fareAttributes selector:@selector(receiveRecord:)];
    [db commit];
    
	NSDate *endDate = [NSDate date];
    
	NSLog(@"FareAttributes entries successfully imported in %f seconds.", [endDate timeIntervalSinceDate:startDate]);
    
    [db close];
    return 0;
}

- (int) addFareRules
{	
	NSDate *startDate = [NSDate date];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[GTFSDatabase autoUpdateDatabasePath]];

    [db setShouldCacheStatements:YES];
    if (![db open]) {
        NSLog(@"Could not open db.");
        //[db release];
        return 1;
    }
	
    NSString *csvString = [self parseForFile:@"fare_rules"];
    
    GTFSFareRules *fareRules = [[GTFSFareRules alloc] initWithDB:db];
    
	CSVParser *parser =
    [[CSVParser alloc]
      initWithString:csvString
      separator:@","
      hasHeader:YES
      fieldNames:nil];
    
    [fareRules cleanupAndCreate];
    [db beginTransaction];
    [parser parseRowsForReceiver:fareRules selector:@selector(receiveRecord:)];
    [db commit];
    
	NSDate *endDate = [NSDate date];
    
	NSLog(@"FareRules entries successfully imported in %f seconds.", [endDate timeIntervalSinceDate:startDate]);
    
    [db close];
	
    return 0;
}

- (int) addRoute
{	
	NSDate *startDate = [NSDate date];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[GTFSDatabase autoUpdateDatabasePath]];

    [db setShouldCacheStatements:YES];
    if (![db open]) {
        NSLog(@"Could not open db.");
        //[db release];
        return 1;
    }
	
    NSString *csvString = [self parseForFile:@"routes"];
    
    GTFSRoute *route = [[GTFSRoute alloc] initWithDB:db];
    
	CSVParser *parser =
    [[CSVParser alloc]
      initWithString:csvString
      separator:@","
      hasHeader:YES
      fieldNames:nil];
    
    [route cleanupAndCreate];
    [db beginTransaction];
    [parser parseRowsForReceiver:route selector:@selector(receiveRecord:)];
    [db commit];
    
	NSDate *endDate = [NSDate date];
    
	NSLog(@"Route entries successfully imported in %f seconds.", [endDate timeIntervalSinceDate:startDate]);
    
    [db close];
	
    return 0;
}

- (int) addShape
{
	NSDate *startDate = [NSDate date];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[GTFSDatabase autoUpdateDatabasePath]];
    
    [db setShouldCacheStatements:YES];
    if (![db open]) {
        NSLog(@"Could not open db.");
        //[db release];
        return 1;
    }
	
    NSString *csvString = [self parseForFile:@"shapes"];
    
    GTFSShape *shape = [[GTFSShape alloc] initWithDB:db];
    
	CSVParser *parser =
    [[CSVParser alloc]
     initWithString:csvString
     separator:@","
     hasHeader:YES
     fieldNames:nil];
    
    [shape cleanupAndCreate];
    [db beginTransaction];
    [parser parseRowsForReceiver:shape selector:@selector(receiveRecord:)];
    [db commit];
    
	NSDate *endDate = [NSDate date];
    
	NSLog(@"Shape entries successfully imported in %f seconds.", [endDate timeIntervalSinceDate:startDate]);
    
    [db close];
	
    return 0;
}

- (int) addStop
{	
	NSDate *startDate = [NSDate date];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[GTFSDatabase autoUpdateDatabasePath]];

    [db setShouldCacheStatements:YES];
    if (![db open]) {
        NSLog(@"Could not open db.");
        //[db release];
        return 1;
    }
	
    NSString *csvString = [self parseForFile:@"stops"];
    
    GTFSStop *stop = [[GTFSStop alloc] initWithDB:db];
    
	CSVParser *parser =
    [[CSVParser alloc]
      initWithString:csvString
      separator:@","
      hasHeader:YES
      fieldNames:nil];
    
    [stop cleanupAndCreate];
    [db beginTransaction];
    [parser parseRowsForReceiver:stop selector:@selector(receiveRecord:)];
    [db commit];
    
	NSDate *endDate = [NSDate date];
    
	NSLog(@"Stop entries successfully imported in %f seconds.", [endDate timeIntervalSinceDate:startDate]);
    
    [db close];
	
    return 0;
}

- (int) addStopRoutes
{
	NSDate *startDate = [NSDate date];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[GTFSDatabase autoUpdateDatabasePath]];
    
    [db setShouldCacheStatements:YES];
    if (![db open]) {
        NSLog(@"Could not open db.");
        //[db release];
        return 1;
    }
    
    GTFSStop *stop = [[GTFSStop alloc] initWithDB:db];
    
	[stop updateRoutes];
    
	NSDate *endDate = [NSDate date];
    
	NSLog(@"Stop entries successfully updated with routes in %f seconds.", [endDate timeIntervalSinceDate:startDate]);
    
    [db close];
	
    return 0;
}

- (int) addStopTime
{
	NSDate *startDate = [NSDate date];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[GTFSDatabase autoUpdateDatabasePath]];

    [db setShouldCacheStatements:YES];
    if (![db open]) {
        NSLog(@"Could not open db.");
        //[db release];
        return 1;
    }
	
    NSString *csvString = [self parseForFile:@"stop_times"];
    
    GTFSStopTime *stopTime = [[GTFSStopTime alloc] initWithDB:db];
    
	CSVParser *parser =
    [[CSVParser alloc]
      initWithString:csvString
      separator:@","
      hasHeader:YES
      fieldNames:nil];
    
    [stopTime cleanupAndCreate];
    [db beginTransaction];
    [parser parseRowsForReceiver:stopTime selector:@selector(receiveRecord:)];
    [db commit];
    
	NSDate *endDate = [NSDate date];
    
	NSLog(@"StopTime entries successfully imported in %f seconds.", [endDate timeIntervalSinceDate:startDate]);
    
    [db close];
	
    return 0;
}

- (int) addTrip
{
	NSDate *startDate = [NSDate date];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[GTFSDatabase autoUpdateDatabasePath]];

    [db setShouldCacheStatements:YES];
    if (![db open]) {
        NSLog(@"Could not open db.");
        //[db release];
        return 1;
    }
	
    NSString *csvString = [self parseForFile:@"trips"];
    
    GTFSTrip *trip = [[GTFSTrip alloc] initWithDB:db];
    
	CSVParser *parser =
    [[CSVParser alloc]
      initWithString:csvString
      separator:@","
      hasHeader:YES
      fieldNames:nil];
    
    [trip cleanupAndCreate];
    [db beginTransaction];
    [parser parseRowsForReceiver:trip selector:@selector(receiveRecord:)];
    [db commit];
    
	NSDate *endDate = [NSDate date];
    
	NSLog(@"Trip entries successfully imported in %f seconds.", [endDate timeIntervalSinceDate:startDate]);
    
    [db close];

    return 0;
}

- (void) vacuum
{
	NSDate *startDate = [NSDate date];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[GTFSDatabase autoUpdateDatabasePath]];
    
    [db setShouldCacheStatements:YES];
    if (![db open]) {
        NSLog(@"Could not open db.");
        //[db release];
    }
    
    [db executeUpdate:@"VACUUM"];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return;
    }
    
    NSDate *endDate = [NSDate date];
    
	NSLog(@"Vaccuuming done in %f seconds.", [endDate timeIntervalSinceDate:startDate]);

    
    [db close];
}

- (void) reindex
{
	NSDate *startDate = [NSDate date];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[GTFSDatabase autoUpdateDatabasePath]];
    
    [db setShouldCacheStatements:YES];
    if (![db open]) {
        NSLog(@"Could not open db.");
        //[db release];
    }
    
    [db executeUpdate:@"REINDEX"];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return;
    }
    
    NSDate *endDate = [NSDate date];
    
	NSLog(@"Reindexing done in %f seconds.", [endDate timeIntervalSinceDate:startDate]);
    
    
    [db close];    
}


@end
