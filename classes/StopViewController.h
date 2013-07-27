//
//  StopViewController.h
//  marguerite
//
//  Created by Kevin Conley on 7/10/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MStop.h"

@interface StopViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) MStop *stop;
@property BOOL isFavoriteStop;
@property (strong, nonatomic) NSArray *nextBuses;

@end
