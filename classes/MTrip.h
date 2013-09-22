//
//  MTrip.h
//  marguerite
//
//  Created by Kevin Conley on 9/18/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTrip : NSObject

@property (strong, nonatomic) NSArray *stopTimes;

- (id) initWithTripId:(NSString *)trip_id;

@end