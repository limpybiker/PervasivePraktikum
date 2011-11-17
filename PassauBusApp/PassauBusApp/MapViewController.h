//
//  MapViewController.h
//  PassauBusApp
//
//  Created by Macbook on 10.11.11.
//  Copyright (c) 2011 Josef Kinseher All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "RMMapView.h"
#import "CMCurrentLocationMarker.h"
#import "RMMapViewDelegate.h"
#import "CMRoutingManager.h"

@interface MapViewController : UIViewController<RMMapViewDelegate> {
    SettingsViewController *settingsController;
    CMCurrentLocationMarker *locationMarker;
    
    IBOutlet RMMapView* mapView;
        
}

@property (nonatomic, strong) IBOutlet SettingsViewController *settingsController;

-(void) addBusStopMarkerAt:(CLLocationCoordinate2D) markerPosition andName:(NSString*)name:(int)iconSize;
-(void) drawRoute;
-(void) drawRoute2;
-(void) setBusStops;
-(void) setBusStops2;



@end
