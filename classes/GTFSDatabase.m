//
//  GTFSDatabase.m
//  marguerite
//
//  Created by Kevin Conley on 7/21/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "GTFSDatabase.h"
#import "CSVImporter.h"

@implementation GTFSDatabase

/* 
 Open the GTFS database and return a reference to it.
 */
+ (GTFSDatabase *) open
{
    GTFSDatabase *db = nil;
    if ((db = [self databaseWithPath:[self getCachePath]])) {
        [db setShouldCacheStatements:YES];
        if (![db open]) {
            NSLog(@"Could not open GTFS db.");
            return nil;
        }
    }
    
    return db;
}

/*
 Uses GTFS text files to create an sqlite3 database in the Caches directory.
 Returns YES if gtfs.db exists in Caches directory afterwards, NO otherwise.
 */
+ (BOOL) create
{
    CSVImporter *importer = [[CSVImporter alloc] init];
    
    NSLog(@"Importing Agency...");
    [importer addAgency];
    
    NSLog(@"Importing Calendar Dates...");
    [importer addCalendarDate];
    
    NSLog(@"Importing Routes...");
    [importer addRoute];
    
    NSLog(@"Importing Shapes...");
    [importer addShape];
    
    NSLog(@"Importing Stops...");
    [importer addStop];
    
    NSLog(@"Importing Trips...");
    [importer addTrip];
    
    NSLog(@"Importing StopTime...");
    [importer addStopTime];
    
    NSLog(@"Vacumming...");
    [importer vacuum];
    
    NSLog(@"Reindexing...");
    [importer reindex];
    
    //For convinience. This will add an extra column 'routes' which will contain comma seperated route numbers passing through this stop
    NSLog(@"Adding routes to stops...");
    [importer addStopRoutes];
    
    NSLog(@"Vacumming...");
    [importer vacuum];
    
    NSLog(@"Reindexing...");
    [importer reindex];
    
    NSLog(@"Import complete!");
    
    BOOL dbExists = [self exists];
    
    NSLog(@"DB file exists: %s", dbExists ? "true" : "false");
    
    return dbExists;
}

/*
 Returns YES if gtfs.db exists in Caches directory, NO otherwise.
 */
+ (BOOL) exists
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self getCachePath]];
}

/*
 Copy the gfts.db file from the Resources folder (bundled with the app) to the Caches directory (/Library/Caches).
 Returns YES if file was copied, returns NO otherwise.
 */
+ (BOOL) copyToCache
{
    NSString *dest = [self getCachePath];
    NSError* error;
    NSString* src = [self getResourcePath];
    
    BOOL dbFileInBundle = [[NSFileManager defaultManager] fileExistsAtPath:src];
    
    if (dbFileInBundle == NO) {
        NSLog(@"copyDatabaseToCacheIfNeeded - GTFS db not in bundle.");
        return NO;
    }
    
    @try {
        [[NSFileManager defaultManager] copyItemAtPath:src toPath:dest error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"copyDatabaseToCacheIfNeeded - Exception: %@", [exception reason]);
        return NO;
    }
    if (error) {
        NSString *messageString = [error localizedDescription];
        messageString = [NSString stringWithFormat:@"%@", messageString];
        NSLog(@"copyDatabaseToCacheIfNeeded - Error: %@", messageString);
        return NO;
    }
    return YES;
}


/*
 Returns the path where the GTFS database will be located in the cache.
 */
+ (NSString *) getCachePath
{
    NSString* cachesDirectory=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [cachesDirectory stringByAppendingPathComponent:@"gtfs.db"];
}

/*
 The path where the GTFS database exists in the Resources folder (bundled with the app).
 */
+ (NSString *) getResourcePath
{
    return [[NSBundle mainBundle] pathForResource:@"gtfs" ofType:@"db"];
}

@end
