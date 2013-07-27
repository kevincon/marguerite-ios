//
//  MRoute.h
//  marguerite
//
//  Created by Kevin Conley on 7/20/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRoute : NSObject

@property (nonatomic, strong) NSString * routeId;
@property (nonatomic, strong) NSString * routeShortName;
@property (nonatomic, strong) NSString * routeLongName;
@property (nonatomic, strong) NSURL * routeUrl;
@property (nonatomic, strong) UIColor * routeColor;
@property (nonatomic, strong) UIColor * routeTextColor;

- (id) initWithRouteIdString:(NSString *) route_id;
- (void) setColorUsingHexString:(NSString *) hexString;
- (void) setTextColorUsingHexString:(NSString *) hexString;

@end
