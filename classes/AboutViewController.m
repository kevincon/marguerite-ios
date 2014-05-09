//
//  AboutViewController.m
//  marguerite
//
//  Created by Kevin Conley on 7/26/13.
//  Copyright (c) 2013 Stanford Devs. All rights reserved.
//

#import "AboutViewController.h"
#import "Constants.h"

#define FEEDBACK_SECTION_INDEX                  0
#define FEEDBACK_BUTTON_ROW                     0
#define FEEDBACK_TWITTER_BUTTON_ROW             1

#define CONTACT_MARGUERITE_SECTION_INDEX        1
#define CONTACT_MARGUERITE_OFFICE_ROW           0
#define CONTACT_MARGUERITE_LOST_AND_FOUND_ROW   1
#define CONTACT_MARGUERITE_WEBSITE_ROW          2

#define APP_SECTION_INDEX                       3

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
    switch (indexPath.section) {
        case FEEDBACK_SECTION_INDEX:
            switch (indexPath.row) {
                case FEEDBACK_BUTTON_ROW:
                    [self openFeedbackView];
                    break;
                case FEEDBACK_TWITTER_BUTTON_ROW:
                    [self openURL:@"http://twitter.com/MargueriteApp"];
            }
            break;
        case CONTACT_MARGUERITE_SECTION_INDEX:
            switch (indexPath.row) {
                case CONTACT_MARGUERITE_OFFICE_ROW:
                    [self openURL:@"tel://650-724-9339"];
                    break;
                case CONTACT_MARGUERITE_LOST_AND_FOUND_ROW:
                    [self openURL:@"tel://650-724-4309"];
                    break;
                case CONTACT_MARGUERITE_WEBSITE_ROW:
                    [self openURL:@"http://transportation.stanford.edu/marguerite/"];
                    break;
            }
            break;
        case APP_SECTION_INDEX:
            [self openURL:@"https://github.com/cardinaldevs/marguerite-ios"];
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section==0) {
        NSDate* lastUpdateDate = [[NSUserDefaults standardUserDefaults] objectForKey:GTFS_DB_LAST_UPDATE_DATE_KEY];
        if (lastUpdateDate!=nil) {
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MMMM dd yyyy"];
            return [NSString stringWithFormat:@"Schedules last updated on %@",[dateFormatter stringFromDate:lastUpdateDate]];
        }
    } else if (section==1) {
        return @"Unclaimed items donated after 30 days.";
    } else if (section==2) {
        return @"This app is open-source. All of the code is available on Github, and anyone can contribute to improving the app.";
    } else if (section==3) {
        return @"This app is open-source. All of the code is available on Github, and anyone can contribute to improving the app.";
    } else if (section==4) {
        return @"Cardinal Devs is an upcoming student organization that develops, maintains, and improves open-source, student-run technology at Stanford University. Applications for new members are accepted at the start of each quarter.";
    }
    return @"";
}

- (void) openFeedbackView {
    [Instabug ShowFeedbackFormWithScreenshot:NO];
}

- (void) openURL:(NSString *)url
{
    NSURL *URL = [NSURL URLWithString:url];
    [[UIApplication sharedApplication] openURL:URL];
}

@end
