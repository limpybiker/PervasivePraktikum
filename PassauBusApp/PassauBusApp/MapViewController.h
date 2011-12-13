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

-(void) addBusStopMarkerAt:(CLLocationCoordinate2D) markerPosition andName:(NSString*)name andSize:(int)iconSize andID:(int)ID;
-(void) drawRoute:plistFileName:(UIColor*)routeColor;
-(void) setBusStops:plistStopsFileName;
-(NSString*) getIconTypeFromZoomLevel:(float)zoomLevel;



@end
