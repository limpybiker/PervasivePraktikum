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
#import "TimetableViewController.h"

@interface MapViewController : UIViewController<RMMapViewDelegate> {
    SettingsViewController *settingsController;
    TimetableViewController *timetableController;
    
    CMCurrentLocationMarker *locationMarker;
    
    IBOutlet RMMapView* mapView;
        
}

@property (nonatomic, strong) IBOutlet SettingsViewController *settingsController;

-(void) repaintMarkers;
-(void) addBusStopMarkerAt:(NSDictionary*) markerData andImage:(UIImage*)image;
-(void) drawRoute:plistFileName:(UIColor*)routeColor;
-(void) setBusStops:plistStopsFileName;
-(NSString*) getIconTypeFromZoomLevel:(float)zoomLevel;



@end
