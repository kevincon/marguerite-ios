//
//  NextBusViewController.h
//  marguerite
//
//  Created by Kevin Conley on 6/24/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocationController.h"

@interface NextShuttleViewController : UITableViewController <CoreLocationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate> {
    CoreLocationController *CLController;
    NSArray *closestStops;
    NSArray *favoriteStops;
    NSArray *allStops;
    NSArray *searchResults;
}

@end
