//
//  SchedulesViewController.h
//  marguerite
//
//  Created by Kevin Conley on 9/18/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoutesViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    NSArray *allRoutes;
}

@end