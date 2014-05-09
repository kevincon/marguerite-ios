//
//  AutoUpdateSplashController.h
//  marguerite
//
//  Created by Hypnotoad on 4/22/14.
//  Copyright (c) 2014 Cardinal Devs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoUpdateSplashController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel* mainStatusLabel;
@property (nonatomic, strong) IBOutlet UILabel* currentActionLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* spinner;
@property (nonatomic, strong) IBOutlet UIProgressView* progressView;

@end
