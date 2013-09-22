//
//  MSchedule.h
//  marguerite
//
//  Created by Kevin Conley on 9/18/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRoute.h"

@interface MSchedule : NSObject

@property (strong, nonatomic) MRoute *route;
@property (strong, nonatomic) NSArray *stops; // The stops from the trips with the most stops for this route today
@property (strong, nonatomic) NSArray *trips; // All trips for this route today

- (id) initWithRoute:(MRoute *) route;

@end