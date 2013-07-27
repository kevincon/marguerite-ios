//
//  RealtimeBuses.h
//  marguerite
//
//  Created by Kevin Conley on 7/16/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TBXML.h"

typedef void (^RealtimeBusesSuccessCallback)(NSArray *);
typedef void (^RealtimeBusesFailureCallback)(NSError *);

@interface RealtimeBuses : NSObject {
    NSString *url;
    NSMutableArray *buses;
    NSMutableDictionary *vehicleIdsToFareboxIds;
    RealtimeBusesSuccessCallback successCallback;
    RealtimeBusesFailureCallback failureCallback;
}

- (id) initWithURL: (NSString *)url andSuccessCallback:(RealtimeBusesSuccessCallback)success andFailureCallback:(RealtimeBusesFailureCallback)failure;
- (void) update;

@end
