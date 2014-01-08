//
//  AppDelegate.m
//  marguerite
//
//  Created by Kevin Conley on 7/8/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "AppDelegate.h"
#import "GTFSDatabase.h"
#import <GoogleMaps/GoogleMaps.h>
#import "secrets.h"
#import "MUtil.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
    
    [Instabug KickOffWithToken:@"ffdb7cae1ed094c68a3a4a6075f7ed15" CaptureSource:InstabugCaptureSourceUIKit FeedbackEvent:InstabugFeedbackEventShake IsTrackingLocation:NO];
    [Instabug setShowEmail:YES];
    [Instabug setShowStartAlert:YES];
    [Instabug setShowThankYouAlert:YES];
    [Instabug setEmailIsRequired:YES];
    [Instabug setCommentIsRequired:YES];
    [Instabug setColorTheme:InstabugColorThemeRed];
    [Instabug setHeaderColor:[MUtil colorFromHexString:@"8C1515"]];
    
    // Copy gfts.db file from app bundle to Caches directory or create gtfs.db if needed
    if ([GTFSDatabase existsInBundle]) {
        if ([GTFSDatabase cacheFileIsStale]) {
            NSLog(@"GTFS file stale in Caches.");
            if (![GTFSDatabase copyToCache]) {
                [GTFSDatabase create];
            } else {
                NSLog(@"Copied GTFS file from bundle to Caches.");
            }
        }
    } else {
        [GTFSDatabase create];
    }
    
    [GMSServices provideAPIKey:GOOGLE_MAPS_API_KEY];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
