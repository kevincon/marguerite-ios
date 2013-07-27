//
//  GMSPanoramaCamera.h
//  Google Maps SDK for iOS
//
//  Copyright 2013 Google Inc.
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://developers.google.com/maps/terms
//

#import <GoogleMaps/GMSOrientation.h>

/**
 * |GMSPanoramaCamera| is used to control the viewing direction of a panorama.
 * It does not contain information about which particular panorama
 * should be displayed (panoramaId), which is stored indepedently.
 */
@interface GMSPanoramaCamera : NSObject

+ (id)cameraWithHeading:(CGFloat)heading pitch:(CGFloat)pitch zoom:(CGFloat)zoom;

+ (id)cameraWithOrientation:(GMSOrientation)orientation zoom:(CGFloat)zoom;


/**
 * Adjusts the visible region of the screen.  A zoom of N will show the
 * same area as the central width/N height/N area of what is shown at zoom 1.
 */
@property(nonatomic, assign, readonly) CGFloat zoom;

/**
 * The camera orientation which groups together heading and pitch.
 */
@property(nonatomic, readonly) GMSOrientation orientation;

@end
