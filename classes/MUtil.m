//
//  MUtil.m
//  marguerite
//
//  Created by Kevin Conley on 7/21/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "MUtil.h"
#import "CSVImporter.h"

@implementation MUtil

/*
 Convert a hex string to a UIColor.
 */
+ (UIColor *) colorFromHexString:(NSString *)hexString {
    NSUInteger rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
