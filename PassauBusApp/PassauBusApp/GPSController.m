//
//  GPSController.m
//  PassauBusApp
//
//  Created by Macbook on 12.11.11.
//  Copyright (c) 2011 Josef Kinseher All rights reserved.
//

#import "GPSController.h"

@implementation GPSController

@synthesize locationManager;

- (id) init {
    self = [super init];
    if (self != nil) {
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        self.locationManager.delegate = self; // send loc updates to myself
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"Location: %@", [newLocation description]);
   
    double horizontalAccuracy = newLocation.horizontalAccuracy;
    
    
    // check if precision is high enough...
    if (horizontalAccuracy <= 60.0) {
        
        NSNumber *longitude = [NSNumber numberWithDouble:newLocation.coordinate.longitude];
        NSNumber *latitude = [NSNumber numberWithDouble:newLocation.coordinate.latitude];
        NSNumber *precision = [NSNumber numberWithDouble:horizontalAccuracy];
        
        NSMutableDictionary *gpsData = [NSMutableDictionary dictionaryWithCapacity:3];
        [gpsData setObject:longitude forKey:@"lo"];
        [gpsData setObject:latitude forKey:@"la"];
        [gpsData setObject:precision forKey:@"p"];
        
        //send out data
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewGpsFix" object:self userInfo:gpsData];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"Error: %@", [error description]);
}

- (void)dealloc {
    [self.locationManager release];
    [super dealloc];
}

@end
