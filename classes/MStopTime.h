//
//  MStopTime.h
//  marguerite
//
//  Created by Kevin Conley on 7/24/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MStopTime : NSObject

@property (nonatomic, strong) NSDate * departureTime;
@property (nonatomic, strong) NSString * routeLongName;
@property (nonatomic, strong) UIColor * routeColor;
@property (nonatomic, strong) UIColor * routeTextColor;
@property (nonatomic, strong) NSString * tripId;

@end
