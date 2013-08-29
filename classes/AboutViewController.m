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

#define CONTACT_MARGUERITE_SECTION_INDEX        1
#define CONTACT_MARGUERITE_OFFICE_ROW           0
#define CONTACT_MARGUERITE_LOST_AND_FOUND_ROW   1
#define CONTACT_MARGUERITE_WEBSITE_ROW          2

#define APP_SECTION_INDEX                       3

#define CLUB_SECTION_INDEX                      5

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void) viewDidLoad
{
    [TestFlight passCheckpoint:@"Visited About tab."];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
    switch (indexPath.section) {
        case FEEDBACK_SECTION_INDEX:
            switch (indexPath.row) {
                case FEEDBACK_BUTTON_ROW:
                    [self openFeedbackView];
                    [TestFlight passCheckpoint:@"Opened feedback submission window."];
                    break;
            }
            break;
        case CONTACT_MARGUERITE_SECTION_INDEX:
            switch (indexPath.row) {
                case CONTACT_MARGUERITE_OFFICE_ROW:
                    [self openURL:@"tel://650-724-9339"];
                    [TestFlight passCheckpoint:@"Called Marguerite office."];
                    break;
                case CONTACT_MARGUERITE_LOST_AND_FOUND_ROW:
                    [self openURL:@"tel://650-724-4309"];
                    [TestFlight passCheckpoint:@"Called Marguerite lost & found."];
                    break;
                case CONTACT_MARGUERITE_WEBSITE_ROW:
                    [self openURL:@"http://transportation.stanford.edu/marguerite/"];
                    [TestFlight passCheckpoint:@"Visited Marguerite website."];
                    break;
            }
            break;
        case APP_SECTION_INDEX:
            [self openURL:@"https://github.com/cardinaldevs/marguerite-ios"];
            [TestFlight passCheckpoint:@"Visited Github page."];
            break;
        case CLUB_SECTION_INDEX:
            [self openURL:@"http://sadevs.stanford.edu"];
            [TestFlight passCheckpoint:@"Visited Cardinal Devs website."];
            break;
    }
}

- (void) openFeedbackView {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Submit Feedback" message:@"Thanks for helping us out!\n\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit", nil];
    _feedbackField = [[UITextField alloc] init];
    [_feedbackField setBackgroundColor:[UIColor whiteColor]];
    _feedbackField.borderStyle = UITextBorderStyleLine;
    _feedbackField.frame = CGRectMake(15, 75, 255, 30);
    _feedbackField.font = [UIFont fontWithName:@"ArialMT" size:20];
    _feedbackField.keyboardAppearance = UIKeyboardAppearanceAlert;
    [_feedbackField becomeFirstResponder];
    [alert addSubview:_feedbackField];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString* feedbackString = _feedbackField.text;
    if ([feedbackString length] <= 0 || buttonIndex == 0){
        return;
    } else if (buttonIndex == 1) {
        [TestFlight submitFeedback:feedbackString];
        return;
    }
}

- (void) openURL:(NSString *)url
{
    NSURL *URL = [NSURL URLWithString:url];
    [[UIApplication sharedApplication] openURL:URL];
}

@end
