//
//  MapViewController.m
//  PassauBusApp
//
//  Created by Macbook on 10.11.11.
//  Copyright (c) 2011 Josef Kinseher All rights reserved.
//

#import "MapViewController.h"
#import "SettingsViewController.h"
#import "RMCloudMadeMapSource.h"
#import "RMMarkerManager.h"
#import "CMCurrentLocationMarker.h"
#import "RMMarkerAdditions.h"
#import "Settings.h"
#import "CustomNotification.h"
#import "GPSController.h"

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

// define the coordinates of the passau city area
const CLLocationDegrees HIGH_LATITUDE = 48.640622;
const CLLocationDegrees LOW_LATITUDE = 48.536159;
const CLLocationDegrees HIGH_LONGITUDE = 13.548203;
const CLLocationDegrees LOW_LONGITUDE = 13.322296;


@implementation MapViewController

@synthesize settingsController;

// constants to set up the view
const int MARKER_TOUCH_SIZE = 44;
const int ROUTE_LINE_WIDTH = 5;
const int NUMBER_OF_BUSES = 15;

// constants to adjust zooming
const float ZOOM_LEVEL_0 = 13.0;
const float ZOOM_LEVEL_1 = 14.5;
const float ZOOM_LEVEL_2 = 15.5;


CLLocationCoordinate2D location;

// holds the marker objects
NSMutableSet *busMarkers;
NSMutableSet *stopMarkers;

// holds the images in different sizes 
UIImage *stopImage_tiny;
UIImage *stopImage_small;
UIImage *stopImage_middle;
UIImage *stopImage_large;

NSMutableDictionary *busImages;


float currentZoomLevel;
double gps_precision;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // get notified when new gps data available
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gpsUpdate:) name:@"NewGpsFix" object:nil]; 
        // get notified when updated bus positions available
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(busUpdate:) name:@"NewBusData" object:nil]; 
        
        // allocate memory for the marker objects
        busMarkers = [[NSMutableSet alloc] init];//[[NSMutableDictionary alloc] init];
        stopMarkers = [[NSMutableSet alloc] init];
        
        // load the images for the bus stops
        stopImage_tiny = [UIImage imageNamed:@"bus_stop_icon10x10.png"];
        stopImage_small = [UIImage imageNamed:@"bus_stop_icon20x20.png"];;
        stopImage_middle = [UIImage imageNamed:@"bus_stop_icon30x30.png"];;
        stopImage_large = [UIImage imageNamed:@"bus_stop_icon40x40.png"];;
        
        // load the images for the buses
        NSString *filePath = [[NSBundle mainBundle] bundlePath];
        NSString *finalPath = [filePath stringByAppendingPathComponent:@"mapBusLineToIcon.plist"];
        busImages = [[NSMutableDictionary dictionaryWithContentsOfFile:finalPath] retain];
        
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [RMMapView class];
    
    mapView.delegate = self;

    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    // -- for the image icons    
    UIImage *image = [UIImage imageNamed:@"SettingsIcon.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );    
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(doSettings:) forControlEvents:UIControlEventTouchUpInside];    
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    image = [UIImage imageNamed:@"MyPosIcon.png"];
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );    
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(doMyPos:) forControlEvents:UIControlEventTouchUpInside];    
    UIBarButtonItem *myPosButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    
    self.navigationItem.title = @"Passau Bus Tracker";
    self.navigationItem.rightBarButtonItem = settingsButton;
    self.navigationItem.leftBarButtonItem = myPosButton;
    
    //this button is shown to go back to this view
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@"Zurück" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    
    [settingsButton release];
    [myPosButton release];
    
    // the map
    id cmTilesource = [[[RMCloudMadeMapSource alloc] initWithAccessKey:@"233109eb10c9495eaea5985221aab1e5" styleNumber:48045] autorelease];
    [[[RMMapContents alloc] initWithView:mapView tilesource: cmTilesource] autorelease];
    
    // set initial position and set zoom level
    CLLocationCoordinate2D start_location;
    start_location.latitude  = 48.57351,0;
    start_location.longitude = 13.45392,0;
    [mapView moveToLatLong: start_location];
    [mapView.contents setZoom: 13.5];
    currentZoomLevel = [mapView.contents zoom];
    
    // adjust zoom levels
    [mapView.contents setMaxZoom:18];
    [mapView.contents setMinZoom:12];
    
}


-(void) viewDidAppear:(BOOL)animated{
    // clear map
    NSArray * contents = [NSArray arrayWithArray:[[mapView.contents overlay] sublayers]];
    [(RMLayerCollection*)[mapView.contents overlay] removeSublayers:contents]; // works
    
    // initialize location marker
    if([_settingsUseGPS boolValue]) {
        if(GPS_ACCESS ) {
            locationMarker = [[CMCurrentLocationMarker alloc] initWithContents:mapView.contents accurancy:100];
            [locationMarker updatePosition:location withAccurnacy:gps_precision];
        }
        else {
            CustomNotification *notifier = [[CustomNotification alloc] init];
            [notifier displayCustomNotificationWithText:@"To see your position the app needs GPS access." inView:self.view];
            [notifier release];
        }
    }
    
    //remove all bus stop markers, if to be displayed they are added again
    [stopMarkers removeAllObjects];
    
    if([_settingsShowRoute4 boolValue]) {
        [self drawRoute:@"route_4_to_achleiten.plist": RGB(140, 108, 83) ];
        [self drawRoute:@"route_4_to_hochstein.plist": RGB(140, 108, 83) ];
    }
    
    if([_settingsShowRoute8 boolValue]){
        [self drawRoute:@"route_8_to_koenigschalding.plist": RGB(245, 136, 142) ];
        [self drawRoute:@"route_8_to_kohlbruck.plist": RGB(245, 136, 142) ];
    }
    
    if([_settingsShowStops boolValue]) {
        if([_settingsShowRoute4 boolValue]){
            [self setBusStops:@"route_4_to_achleiten_stops.plist"];
            [self setBusStops:@"route_4_to_hochstein_stops.plist"];
        }
    
        if([_settingsShowRoute8 boolValue]) {
            [self setBusStops:@"route_8_to_koenigschalding_stops.plist"];
            [self setBusStops:@"route_8_to_kohlbruck_stops.plist"];
        }
    }
    
}

-(void) drawRoute:(NSString*)plistFileName:(UIColor*)routeColor {
    
    // read plist from application bundle
    NSString *filePath = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [filePath stringByAppendingPathComponent:plistFileName];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    
    NSArray *coordinates = [dictionary objectForKey:@"coordinates"];
    
    RMPath *path = [[RMPath alloc] initForMap:mapView];
    CLLocationCoordinate2D pathCoordinate;
    
    for(int i=0; i<[coordinates count]; i++) {
        NSArray *position = [coordinates objectAtIndex:i];
        
        pathCoordinate.longitude = [[position objectAtIndex:1] doubleValue];
        pathCoordinate.latitude  = [[position objectAtIndex:0] doubleValue];
        
        [path addLineToLatLong:pathCoordinate];
    }
    
    path.lineColor = routeColor;
    path.fillColor = [UIColor clearColor];
    path.lineWidth = ROUTE_LINE_WIDTH;
    path.scaleLineWidth = NO;
    [mapView.contents.overlay addSublayer:path]; 
    [path release];
}


-(void) setBusStops:(NSString*)plistStopsFileName {
    // read plist from application bundle
    NSString *filePath = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [filePath stringByAppendingPathComponent:plistStopsFileName];
    NSDictionary *stops = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    NSArray *coordinates = [stops objectForKey:@"stops"];
    NSString *routeNumber = [stops objectForKey:@"route_number"];
    NSString *routeDestination = [stops objectForKey:@"route_destination"];
    
    // read "busStopIcons.plist"
    NSString *filePath2 = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath2 = [filePath2 stringByAppendingPathComponent:@"busStopIcons.plist"];
    NSDictionary *imageNameDict = [NSDictionary dictionaryWithContentsOfFile:finalPath2];

    //chose correct image according to zoom level
    NSString *iconType = [self getIconTypeFromZoomLevel:[mapView.contents zoom]];
    NSString *imageName = [imageNameDict objectForKey:iconType];
    UIImage *image = [UIImage imageNamed:imageName];
    
        
    for(int i=0; i<[coordinates count]; i++) {
        // create dictionary with all the info belonging to a marker
        NSMutableDictionary *markerData = [[[NSMutableDictionary alloc] init] autorelease];
        [markerData setValue:routeNumber forKey:@"route_number"];
        [markerData setValue:routeDestination forKey:@"route_destination"];
            
        NSArray *position = [coordinates objectAtIndex:i];
        [markerData setValue:[position objectAtIndex:0] forKey:@"name"];
        [markerData setValue:[position objectAtIndex:1] forKey:@"latitude"];
        [markerData setValue:[position objectAtIndex:2] forKey:@"longitude"];
        
        [self addBusStopMarkerAt:markerData andImage:image];
    }
}

- (void) setText: (NSString*)text forMarker: (RMMarker*) marker {
    CGSize textSize = [text sizeWithFont: [RMMarker defaultFont]]; 
    CGPoint position = CGPointMake(  -(textSize.width/2 - marker.bounds.size.width/2), -textSize.height );
    [marker changeLabelUsingText: text position: position ];    
}

// update navigation bar on tap on item
- (void) tapOnMarker: (RMMarker*) marker onMap: (RMMapView*) map {
    // handle stop marker
    if([stopMarkers containsObject:marker]) {    
        NSString *name = [(NSDictionary *)marker.data objectForKey:@"name"];
        TimetableViewController *timetableViewController = [[TimetableViewController alloc] initWithString:name];
        [self.navigationController pushViewController:timetableViewController animated:YES];
        [timetableViewController release];
    }
    
    //handle bus marker
    if([busMarkers containsObject:marker]) {    
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size: 18.0];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor whiteColor]];
        [label setText:[NSString stringWithFormat:@"Linie%i - %@", [[(NSDictionary *)marker.data objectForKey:@"route_number"] intValue], [(NSDictionary *)marker.data objectForKey:@"route_destination"]]];
        [label sizeToFit];
        [self.navigationItem setTitleView:label];
        [label release];
    }
}


// reset navigation bar on double Tap on Map
- (void) doubleTapOnMap: (RMMapView*) map At: (CGPoint) point {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size: 18.0];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:@"Passau Bus Tracker"];
    [label sizeToFit];
    [self.navigationItem setTitleView:label];
    [label release];
}


-(void) addBusStopMarkerAt:(NSDictionary*) markerData andImage:(UIImage*)image {
    
    // set marker
    RMMarker *marker = [[RMMarker alloc] initWithUIImage:image anchorPoint:CGPointMake(0.5, 0.5)];
    [stopMarkers addObject:marker];
    
    CLLocationCoordinate2D markerPosition;
    markerPosition.latitude = [[markerData objectForKey:@"latitude"] doubleValue];
    markerPosition.longitude = [[markerData objectForKey:@"longitude"] doubleValue];
    [mapView.contents.markerManager addMarker:marker AtLatLong:markerPosition];
    
    marker.data = markerData;
        
    [marker release];
}

-(void) addBusMarkerAt:(NSDictionary*) busData andID:(int)ID {
    
    NSDictionary *busLineImages = [busImages objectForKey: [busData objectForKey:@"route_number"]];
    NSString *imageName = [busLineImages objectForKey:[self getIconTypeFromZoomLevel:[mapView.contents zoom]]];
    UIImage *image = [UIImage imageNamed:imageName];
            
    double longitude = [[busData objectForKey:@"longitude"] doubleValue];
    double latitude = [[busData objectForKey:@"latitude"] doubleValue];    
    CLLocationCoordinate2D busCoordinate;
    busCoordinate.longitude = longitude;
    busCoordinate.latitude  = latitude;
    
    // set marker
    RMMarker *marker = [[RMMarker alloc] initWithUIImage:image anchorPoint:CGPointMake(0.5, 0.5)];
    marker.data = busData;
    [mapView.contents.markerManager addMarker:marker AtLatLong:busCoordinate];
        
    [busMarkers addObject:marker];
    
    [marker release];
}

- (void) beforeMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
}

- (void) afterMapZoom:(RMMapView *)map byFactor:(float)zoomFactor near:(CGPoint)center {
    [self repaintMarkers];
}

-(void) repaintMarkers{
    BOOL repaint = NO;
    UIImage *stop_image = nil;
    
    //NSLog(@"currentZoomLevel %f ", currentZoomLevel);
    
    double zoomLevel = [mapView.contents zoom];
    
    if((zoomLevel < ZOOM_LEVEL_0) && (currentZoomLevel > ZOOM_LEVEL_0)) {
        repaint = YES;
        stop_image = stopImage_tiny;
    }
    else if((zoomLevel < ZOOM_LEVEL_1) && (zoomLevel > ZOOM_LEVEL_0) && ((currentZoomLevel > ZOOM_LEVEL_1) || (currentZoomLevel < ZOOM_LEVEL_0))) {
        repaint = YES;
        stop_image = stopImage_small;
    }
    else if((zoomLevel < ZOOM_LEVEL_2) && (zoomLevel > ZOOM_LEVEL_1) && ((currentZoomLevel < ZOOM_LEVEL_1) || (currentZoomLevel > ZOOM_LEVEL_2))) {
        repaint = YES;
        stop_image = stopImage_middle;
    }
    else if((zoomLevel > ZOOM_LEVEL_2) && (currentZoomLevel < ZOOM_LEVEL_2)) {
        repaint = YES;
        stop_image = stopImage_large;
    }
    
    currentZoomLevel = [mapView.contents zoom];
    
    if(repaint) {
        // repaint all bus stop markers
        for(int i= 0; i<[[stopMarkers allObjects] count]; i++) {
            [[[stopMarkers allObjects] objectAtIndex:i] replaceUIImage:stop_image anchorPoint:CGPointMake(0.5, 0.5)];
        }
    }
    
    if(GPS_ACCESS) {
        [locationMarker updatePosition:location withAccurnacy:gps_precision];
    }
     
}



// return either tiny, small, middle oder large as image size
- (NSString*)getIconTypeFromZoomLevel:(float)zoomLevel {
    NSString *iconType = [[[NSString alloc] init] autorelease];
    if(zoomLevel <= ZOOM_LEVEL_0) {
        iconType = @"tiny";
    }
    if((zoomLevel <= ZOOM_LEVEL_1) && (zoomLevel > ZOOM_LEVEL_0)) {
        iconType = @"small";
    }
    if((zoomLevel <= ZOOM_LEVEL_2) && (zoomLevel > ZOOM_LEVEL_1)) {
        iconType = @"middle";
    }
    if(zoomLevel > ZOOM_LEVEL_2) {
        iconType = @"large";
    }    
    return iconType;
}


-(void)doSettings:(id)sender {
    NSLog(@"settings pressed");
    settingsController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];    
    [self.navigationController pushViewController:settingsController animated:YES];    
}

// updates the bus positions on the map
- (void)busUpdate:(NSNotification *)theNotification {
    NSLog(@"new bus position available");
    
    NSArray *busData = [theNotification.userInfo objectForKey:@"messages"];    
    
    //remove all bus markers and clear marker list
    for(int i= 0; i<[[busMarkers allObjects] count]; i++) {
        [mapView.contents.markerManager removeMarker:[[busMarkers allObjects] objectAtIndex:i]];
    }
    [busMarkers removeAllObjects];
    
    // display updated bus markers on the map
    for(int i=0; i<[busData count]; i++) {
        int bus_id = [[[busData objectAtIndex:i] objectForKey:@"bus_id"] intValue];
        [self addBusMarkerAt:[busData objectAtIndex:i] andID:bus_id];
    }
    
}


-(void)doMyPos:(id)sender {
    
    if(GPS_ACCESS) {
        if(location.latitude >= LOW_LATITUDE && location.latitude <= HIGH_LATITUDE && location.longitude >= LOW_LONGITUDE && location.longitude <= HIGH_LONGITUDE) {
            [mapView moveToLatLong: location];
            
            if([_settingsUseGPS boolValue])
                [locationMarker updatePosition:location withAccurnacy:gps_precision];

        } else {
            NSLog(@"showNotification");
            CustomNotification *notifier = [[CustomNotification alloc] init];
            [notifier displayCustomNotificationWithText:@"To use this function you must be located in the Passau city area." inView:self.view];
            [notifier release];
        }
    } else {
        CustomNotification *notifier = [[CustomNotification alloc] init];
        [notifier displayCustomNotificationWithText:@"To navigate to your position the app needs GPS access." inView:self.view];
        [notifier release];
    }
}

// called when new gps fix available
// updates user's position on the map
- (void)gpsUpdate:(NSNotification *)theNotification {
    NSLog(@"new gps fix available");
    double latitude = [[theNotification.userInfo objectForKey:@"la"] doubleValue];
    double longitude = [[theNotification.userInfo objectForKey:@"lo"] doubleValue];
    gps_precision = [[theNotification.userInfo objectForKey:@"p"] doubleValue];
    
    location.longitude = longitude;
    location.latitude  = latitude;
    
    if([_settingsUseGPS boolValue])
    [locationMarker updatePosition:location withAccurnacy:gps_precision];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
}


-(void) dealloc {
    [super dealloc];
}

@end
