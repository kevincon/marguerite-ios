//
//  AutoUpdateSplashController.m
//  marguerite
//
//  Created by Hypnotoad on 4/22/14.
//  Copyright (c) 2014 Cardinal Devs. All rights reserved.
//

#import "AutoUpdateSplashController.h"
#import "GTFSUnarchiver.h"
#import "secrets.h"
#import "GTFSDatabase.h"
#import "AppDelegate.h"
#import "DataDownloader.h"
#import "Constants.h"

@interface AutoUpdateSplashController ()<GTFSDatabaseCreationProgressDelegate, DataDownloadDone>

@property (strong, nonatomic) GTFSUnarchiver* gtfsUpdater;
@property (strong, nonatomic) DataDownloader* dataDownloader;

@end

@implementation AutoUpdateSplashController

@synthesize gtfsUpdater;
@synthesize dataDownloader;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.gtfsUpdater = [[GTFSUnarchiver alloc] init];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startUpdate];
}

- (void) viewWillDisappear:(BOOL)animated {
    [dataDownloader cancelDownload];
    [super viewWillDisappear:animated];
}

- (void) startUpdate {
    self.progressView.progress = 0.0;
    [self.spinner startAnimating];
    NSString* localTransitZipFileFullPath = [GTFSUnarchiver fullPathToDownloadedTransitZippedFile];
    self.dataDownloader = [[DataDownloader alloc] initWithURL:[NSURL URLWithString:MARGUERITE_TRANSIT_DATA_URL] localPath:localTransitZipFileFullPath downloadDelegate:self];
    [dataDownloader startDownload];
}

#pragma mark data download done delegate

- (void) dataDownloadDone:(NSData*)data {
    NSLog(@"updatedData downloaded");
    _currentActionLabel.text = @"Updating GTFS database";
    _mainStatusLabel.text = @"Updating schedule data...";
    dispatch_queue_t dbUpdateQ = dispatch_queue_create("GTFS DB UPDATE", NULL);
    dispatch_async(dbUpdateQ, ^ {
        BOOL updateSuccess = [gtfsUpdater unzipTransitZipFile] && [GTFSDatabase create:self];
        BOOL activateSuccess = [GTFSDatabase activateNewAutoUpdateBuildIfAvailable];
        dispatch_async(dispatch_get_main_queue(), ^ {
            if (updateSuccess && activateSuccess) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:GTFS_DB_LAST_UPDATE_DATE_KEY];
                [self finishedAutoUpdate];
            } else {
                [self showErrorAlert:@"Error updating and activating data. Will retry next launch."];
            }
        });
    });
}

- (void) cachedDataDownloadDone:(NSData*)data {
    NSLog(@"cachedData downloaded");
    [self finishedAutoUpdate];
}

- (void) dataDownloadFailed:(NSError*)error {
    NSLog(@"Error attempting download : %@",[error localizedDescription]);
    [self finishedAutoUpdate];
}

#pragma mark alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self finishedAutoUpdate];
}

#pragma mark updater delegate

- (void) updatingStepNumber:(NSInteger)currentStep outOfTotalSteps:(NSInteger)totalSteps currentStepLabel:(NSString*)stepDesc {
    dispatch_async(dispatch_get_main_queue(), ^ {
        self.currentActionLabel.text = stepDesc;
        self.progressView.progress = (float)currentStep / (float)totalSteps;
        if (currentStep==totalSteps) {
            [self.spinner stopAnimating];
        }
    });
}

#pragma mark private methods

- (void) showErrorAlert:(NSString*)errorMsg {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void) finishedAutoUpdate {
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.autoUpdateInProgress = NO;
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
