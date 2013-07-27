//
//  GTFSDatabase.h
//  marguerite
//
//  Created by Kevin Conley on 7/21/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface GTFSDatabase : FMDatabase

+ (GTFSDatabase *) open;
+ (BOOL) create;
+ (BOOL) exists;
+ (BOOL) copyToCache;
+ (NSString *) getCachePath;
+ (NSString *) getResourcePath;

@end
