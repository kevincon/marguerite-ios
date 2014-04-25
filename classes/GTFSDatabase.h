//
//  GTFSDatabase.h
//  marguerite
//
//  Created by Kevin Conley on 7/21/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@protocol GTFSDatabaseCreationProgressDelegate <NSObject>

- (void) updatingStepNumber:(NSInteger)currentStep outOfTotalSteps:(NSInteger)totalSteps currentStepLabel:(NSString*)stepDesc;

@end

@interface GTFSDatabase : FMDatabase

+ (GTFSDatabase *) open;
+ (BOOL) create:(NSObject<GTFSDatabaseCreationProgressDelegate>*)creationProgressDelegate;
+ (BOOL) activateNewAutoUpdateBuildIfAvailable;
+ (NSString *) getNewAutoUpdateDatabaseBuildPath;

@end
