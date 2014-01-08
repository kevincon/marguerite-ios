//
//  AboutViewController.m
//  marguerite
//
//  Created by Kevin Conley on 7/26/13.
//  Copyright (c) 2013 Stanford Devs. All rights reserved.
//

#import "AboutViewController.h"

#define FEEDBACK_SECTION_INDEX                  0
#define FEEDBACK_BUTTON_ROW                     0
#define FEEDBACK_TWITTER_BUTTON_ROW             1

#define CONTACT_MARGUERITE_SECTION_INDEX        1
#define CONTACT_MARGUERITE_OFFICE_ROW           0
#define CONTACT_MARGUERITE_LOST_AND_FOUND_ROW   1
#define CONTACT_MARGUERITE_WEBSITE_ROW          2

#define APP_SECTION_INDEX                       3

#define CLUB_SECTION_INDEX                      5

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
        case CLUB_SECTION_INDEX:
            [self openURL:@"http://sadevs.stanford.edu"];
            break;
    }
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
