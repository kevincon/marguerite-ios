//
//  ScheduleViewController.h
//  marguerite
//
//  Created by Kevin Conley on 9/18/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDSpreadViewClasses.h"
#import "MSchedule.h"

@interface ScheduleViewController : UIViewController <MDSpreadViewDataSource, MDSpreadViewDelegate>

@property (strong, nonatomic) MSchedule *schedule;
@property (weak, nonatomic) IBOutlet MDSpreadView *spreadView;

@end