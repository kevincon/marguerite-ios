//
//  RealtimeBuses.m
//  marguerite
//
//  Created by Kevin Conley on 7/16/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "RealtimeBuses.h"
#import "MRealtimeBus.h"
#import "TBXML+HTTP.h"
#import "secrets.h"
#import <ASIHTTPRequest/ASIFormDataRequest.h>

@implementation RealtimeBuses

/*
 Return a RealtimeBuses object given the URL of the bus XML feed and callback methods for success 
 and failure.
 */
- (id) initWithURL: (NSString *)theUrl andSuccessCallback:(RealtimeBusesSuccessCallback)success andFailureCallback:(RealtimeBusesFailureCallback)failure
{
    if (self = [super init]) {
        url = theUrl;
        successCallback = success;
        failureCallback = failure;
    }
    return self;
}

/*
 Refresh the buses by polling the XML feed. Calls the appropriate success/failure callback with
 an array of the buses or an error.
 */
- (void) update
{
    [TBXML tbxmlWithURL:[NSURL URLWithString:url]
                success:^(TBXML *tbxml) {
                    buses = nil;
                    if ((buses = [self traverseVehicles:tbxml.rootXMLElement])) {
                        [self updateFareboxIds:[self extractVehicleIdsFromBuses:buses]];
                    } else {
                        failureCallback([self errorWithString:@"Real-time feed invalid"]);
                    }
                }
                failure:^(TBXML *tbxml, NSError *error) {
                    NSLog(@"RealtimeBuses updateBuses error: %@", [error localizedDescription]);
                    failureCallback(error);
                }
     ];
}

/*
 Populate the 'buses' instance dictionary with mappings from gtfs route_id to CLLocation.
 */
- (void) updateBuses
{
    NSMutableArray *updatedBuses = [[NSMutableArray alloc] init];
    for (MRealtimeBus *bus in buses) {
        if (bus.vehicleId == nil) {
            continue;
        }
        
        NSString *fareboxId = vehicleIdsToFareboxIds[bus.vehicleId];
        if (fareboxId == nil || [fareboxId isEqualToString:@"-1"]) {
            continue;
        }
        
        NSString *route_id = [self getRouteIdWithFareboxId:fareboxId];
        bus.route = [[MRoute alloc] initWithRouteIdString:route_id];
        if (bus.route != nil) {
            [updatedBuses addObject:bus];
        }
    }

    successCallback(updatedBuses);
}

/*
 Given an array of bus dictionaries, return a string containing the vehicle IDs of the buses 
 separated by commas. (to be used in making a POST request to get farebox IDs)
 */
-(NSString *) extractVehicleIdsFromBuses:(NSArray *)busArray
{
    NSMutableArray *vehicleNames = [[NSMutableArray alloc] init];
    
    for (MRealtimeBus* bus in busArray) {
        NSString *vehicleId = bus.vehicleId;
        if (vehicleId && [vehicleId integerValue] != 0) {
            [vehicleNames addObject:vehicleId];
        }
    }
    
    return [vehicleNames componentsJoinedByString:@","];
}

/* 
 Given a string containing vehicle IDs separated by commas, make a POST request to get the mappings 
 from vehicle IDs to farebox IDs and update the instance dictionary 'vehicleIdsToFareboxIds' 
 accordingly. Then call updateBuses() to update the 'buses' instance dictionary.
 */
- (void) updateFareboxIds:(NSString *)vehicleNames
{
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:MARGUERITE_VEHICLE_IDS_URL]];
    [request setPostValue:vehicleNames forKey:@"name"];
    [request setCompletionBlock:^{
        // Use when fetching text data
        NSString *responseString = [request responseString];
        NSError* jsonError = nil;
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
        
        NSArray *mappings = jsonData[@"DATA"];
        if (jsonData == nil) {
            failureCallback([self errorWithString:@"Farebox ID JSON parsing failed."]);
        }
        
        vehicleIdsToFareboxIds = [[NSMutableDictionary alloc] init];
        
        for (NSArray* mapping in mappings) {
            if ([mapping count] == 2) {
                NSNumber *vehicleId = mapping[0];
                NSNumber *fareboxId = mapping[1];
                vehicleIdsToFareboxIds[[NSString stringWithFormat:@"%d", [vehicleId integerValue]]] = [fareboxId stringValue];
            }
        }
        
        [self updateBuses];
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        failureCallback(error);
    }];
    [request startAsynchronous];
}

/*
 Given the root element of the real-time shuttle location XML feed, traverse the vehicles and 
 return an array of MRealtimeBus's containing information about the buses, or nil on error.
 */
- (NSMutableArray *) traverseVehicles:(TBXMLElement *)element
{
    if (element == nil || element->firstChild == nil) {
        return nil;
    }
    
    element = element->firstChild;
    
    NSMutableArray *busArray = [[NSMutableArray alloc] init];
    do {
        if ([[TBXML elementName:element] isEqualToString:@"vehicle"]) {
            MRealtimeBus *bus = [self traverseVehicleElement:element];
            if (bus) {
                [busArray addObject:bus];
            }
        }
        // Obtain next sibling element
    } while ((element = element->nextSibling));
    return busArray;
}

/* 
 Given a vehicle XML element, return an MRealtimeBus containing the child elements/values and
 attributes or nil if bus is not valid.
 */
- (MRealtimeBus *) traverseVehicleElement:(TBXMLElement *)element
{
    NSMutableDictionary *busDictionary = [[NSMutableDictionary alloc] init];
    
    // Obtain first attribute from vehicle element
    TBXMLAttribute * attribute = element->firstAttribute;

    while (attribute) {
        // Put the bus attribute in the bus dictionary
        busDictionary[[TBXML attributeName:attribute]] = [TBXML attributeValue:attribute];
        
        // Obtain the next attribute
        attribute = attribute->next;
    }
    
    // Put the vehicle's child elements in the bus dictionary
    TBXMLElement *currentElement = element->firstChild;
    while (currentElement) {
        busDictionary[[TBXML elementName:currentElement]] = [TBXML textForElement:currentElement];
        currentElement = currentElement->nextSibling;
    }

    NSString *vid = busDictionary[@"name"];
    NSString *latitude = busDictionary[@"latitude"];
    NSString *longitude = busDictionary[@"longitude"];
    NSString *gpsStatus = busDictionary[@"gps-status"];
    NSString *opStatus = busDictionary[@"op-status"];
    
    if (vid == nil ||
        gpsStatus == nil ||
        [gpsStatus isEqualToString:@"good"] == NO ||
        opStatus == nil ||
        //[opStatus isEqualToString:@"none"] == NO ||
        latitude == nil ||
        longitude == nil) {
        return nil;
    }
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
    
    MRealtimeBus *bus = [[MRealtimeBus alloc] init];
    bus.vehicleId = vid;
    bus.location = location;
    bus.dictionary = busDictionary;
    
    return bus;
}

/*
 The XML feed identifies buses using a (mostly) 4-digit ID in the name element, called a vehicle ID. 
 The vehicle ID is translated to a farebox ID using the POST request in "updateFareboxIds", and this 
 function translates a farebox ID into the corresponding gtfs route_id.
 */
- (NSString *) getRouteIdWithFareboxId:(NSString *)fareboxId
{
    switch ([fareboxId integerValue]) {
        case 8888:
            //Stanford Menlo Park
            return @"40";
        case 9999:
            //Bohannon
            return @"53";
        case 2:
            //Line Y (Clockwise)
            return @"2";
        case 3:
            //Line X (Counter-Clockwise)
            return @"3";
        case 4:
            //Line C
            return @"4";
        case 5:
            //Tech
            return @"54";
        case 8:
            //SLAC
            return @"8";
        case 9:
            //Line N
            return @"9";
        case 10:
            //Line O
            return @"43";
        case 11:
            //Shopping Express
            return @"18";
        case 15:
            //Line V
            return @"15";
        case 17:
            //Line P
            return @"20";
        case 19:
            //Medical Center
            return @"22";
        case 23:
            //1050 Arastradero
            return @"28";
        case 28:
            //Line S
            return @"33";
        case 29:
            //Ardenwood Express
            return @"36";
        case 30:
            //Research Park
            return @"38";
        case 32:
            //Stanford Menlo Park
            return @"40";
        case 33:
            //Bohannon
            return @"53";
        case 40:
            //Line Y
            return @"2";
        case 42:
            //Line Y Limited
            return @"44";
        case 43:
            //Line X Limited
            return @"45";
        case 44:
            //Line C Limited
            return @"46";
        case 46:
            //OCA
            return @"56";
        case 47:
            //Electric N
            return @"9";
        case 48:
            //Medical Center Limited
            return @"47";
        case 49:
            //Medical Center Limited
            return @"47";
        case 50:
            //EB ???
            return nil;
        case 51:
            //Electric 1050A
            return @"28";
        case 52:
            //Electric BOH
            return @"53";
        case 53:
            //Electric Y
            return @"2";
        case 54:
            //Electric C
            return @"4";
        case 55:
            //Electric MC
            return @"22";
        case 56:
            //Electric MC-H
            return @"50";
        case 57:
            //Electric O
            return @"43";
        case 58:
            //Electric P
            return @"20";
        case 59:
            //Electric RP
            return @"38";
        case 60:
            //Electric SE
            return @"18";
        case 61:
            //Electric SLAC
            return @"8";
        case 62:
            //Electric SMP
            return @"40";
        case 63:
            //Electric TECH
            return @"54";
        case 64:
            //Electric V
            return @"15";
        case 65:
            //Electric X
            return @"3";
        default:
            return nil;
    }
}

/*
 Return a generic NSError object with the given message.
 */
- (NSError *) errorWithString:(NSString *)message
{
    NSMutableDictionary *details = [NSMutableDictionary dictionary];
    [details setValue:message forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"world" code:200 userInfo:details];
}

@end
