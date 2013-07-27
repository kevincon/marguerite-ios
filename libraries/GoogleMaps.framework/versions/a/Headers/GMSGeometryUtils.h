//
//  GMSGeometryUtils.h
//  Google Maps SDK for iOS
//
//  Copyright 2013 Google Inc.
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://developers.google.com/maps/terms
//

#import <CoreLocation/CoreLocation.h>

/**
 * Returns the geodesic or great circle distance between two coordinates.
 * This is the shortest distance between the two coordinates on the sphere.
 * Both coordinates should be valid.
 */
FOUNDATION_EXPORT
CLLocationDistance GMSGeometryDistance(CLLocationCoordinate2D from,
                                       CLLocationCoordinate2D to);

/**
 * Returns the initial heading (degrees clockwise of North) at |from|
 * of the shortest path to |to|.
 * Returns 0 if the two coordinates are the same.
 * Both coordinates should be valid.
 * The returned value is in the range [0, 360).
 *
 * To get the final heading at |to| one may use
 * (GMSGeometryHeading(|to|, |from|) + 180) modulo 360.
 */
FOUNDATION_EXPORT
CLLocationDirection GMSGeometryHeading(CLLocationCoordinate2D from,
                                       CLLocationCoordinate2D to);

/**
 * Returns the destination coordinate, when starting at |from|
 * with initial |heading|, travelling |distance| meters along a great circle
 * arc.
 * The resulting longitude is in the range [-180, 180).
 */
FOUNDATION_EXPORT
CLLocationCoordinate2D GMSGeometryOffset(CLLocationCoordinate2D from,
                                         CLLocationDistance distance,
                                         CLLocationDirection heading);

/**
 * Returns the coordinate that lies the given |fraction| of the way between
 * the |from| and |to| coordinates on the shortest path between the two.
 * The resulting longitude is in the range [-180, 180).
 */
FOUNDATION_EXPORT
CLLocationCoordinate2D GMSGeometryInterpolate(CLLocationCoordinate2D from,
                                              CLLocationCoordinate2D to,
                                              double fraction);
