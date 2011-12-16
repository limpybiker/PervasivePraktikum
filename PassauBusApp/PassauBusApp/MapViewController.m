//
//  MapViewController.m
//  PassauBusApp
//
//  Created by Macbook on 10.11.11.
//  Copyright (c) 2011 Josef Kinseher All rights reserved.
//



// überlagerung der Bushaltestellen --> id's ?
// namen der haltestellen: wie auf klick, in navBar, zoomabhängig
// settings: graphik
// settings _> zu viel infos in map? reduzieren durch zeige Haltestellen, ...
// achleiten stops
// linien, größe der pngs: zoomabhängig, fest ?

// plist mit namen aller plisten => um automatisiert einzulesen

#import "MapViewController.h"
#import "SettingsViewController.h"
#import "RMCloudMadeMapSource.h"
#import "RMMarkerManager.h"
#import "CMCurrentLocationMarker.h"
#import "RMMarkerAdditions.h"
#import "Settings.h"

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]


@implementation MapViewController

@synthesize settingsController;

const int MARKER_TOUCH_SIZE = 44;
const int ROUTE_LINE_WIDTH = 5;
const int NUMBER_OF_BUSES = 15;

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


//TODO: initial size variable für ALLE icons
//TODO: GLOBALE ID's in PList für alle bus stops

//TODO: bus ids werden gesendet, bisher aber nicht mehr benötigt


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
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [RMMapView class];
    
    // action handling
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
    
    [image release];
    [button release];
    
    
    self.navigationItem.title = @"Bus Tracker";
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
    location.latitude  = 48.57351,0;
    location.longitude = 13.45392,0;
    [mapView moveToLatLong: location];
    [mapView.contents setZoom: 13];
    currentZoomLevel = [mapView.contents zoom];
    
    // adjust zoom levels
    [mapView.contents setMaxZoom:18];
    [mapView.contents setMinZoom:10];
    
    
    // initialize location marker
    locationMarker = [[CMCurrentLocationMarker alloc] initWithContents:[mapView contents] accurancy:0];    
    
    if (![CLLocationManager locationServicesEnabled])
        NSLog(@"GPS is not enabled");
    

}


-(void) viewDidAppear:(BOOL)animated{
    
    // clear map
    NSArray * contents = [NSArray arrayWithArray:[[mapView.contents overlay] sublayers]];
    [(RMLayerCollection*)[mapView.contents overlay] removeSublayers:contents]; // works
    
    //remove all bus stop markers, if to be displayed they are added again
    [stopMarkers removeAllObjects];
    
    // BOOLEAN VERWENDEN statt string
    if([_settingsShowRoute4 isEqualToString:@"true"]){
        [self drawRoute:@"route_4_to_achleiten.plist": RGB(140, 108, 83) ];
        [self drawRoute:@"route_4_to_hochstein.plist": RGB(140, 108, 83) ];
    }
    
    if([_settingsShowRoute8 isEqualToString:@"true"]){
        [self drawRoute:@"route_8_to_koenigschalding.plist": RGB(245, 136, 142) ];
        [self drawRoute:@"route_8_to_kohlbruck.plist": RGB(245, 136, 142) ];
    }
    
    if([_settingsShowStops isEqualToString:@"true"]) {
        if([_settingsShowRoute4 isEqualToString:@"true"]){
            [self setBusStops:@"route_4_to_achleiten_stops.plist"];
            [self setBusStops:@"route_4_to_hochstein_stops.plist"];
        }
    
        if([_settingsShowRoute8 isEqualToString:@"true"]) {
            [self setBusStops:@"route_8_to_koenigschalding_stops.plist"];
            [self setBusStops:@"route_8_to_kohlbruck_stops.plist"];
        }
    }
    
}

-(void) drawRoute:(NSString*)plistFileName:(UIColor*)routeColor {
    
    // read "foo.plist" from application bundle
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
    
}


-(void) setBusStops:(NSString*)plistStopsFileName {
    // read "foo.plist" from application bundle
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
        
        
        // statt id dict mitgeben? für infos an marker
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
    NSLog(@"Name: %@", marker.data);
    // handle stop marker
    if([stopMarkers containsObject:marker]) {    
        TimetableViewController *timetableViewController = [[TimetableViewController alloc] init];
        timetableViewController.title = [(NSDictionary *)marker.data objectForKey:@"name"];
        [self.navigationController pushViewController:timetableViewController animated:YES];
    }
    
    //handle bus marker
    if([busMarkers containsObject:marker]) {    
        
    }
}


// reset navigation bar on double Tap on Map
- (void) doubleTapOnMap: (RMMapView*) map At: (CGPoint) point {
    self.navigationItem.title = @"Passau Bus App";
}


// TODO Parameter size weg
-(void) addBusStopMarkerAt:(NSDictionary*) markerData andImage:(UIImage*)image {
    
    // set marker
    RMMarker *marker = [[RMMarker alloc] initWithUIImage:image anchorPoint:CGPointMake(0.5, 0.5)];
    [stopMarkers addObject:marker];
    
    CLLocationCoordinate2D markerPosition;
    markerPosition.latitude = [[markerData objectForKey:@"latitude"] doubleValue];
    markerPosition.longitude = [[markerData objectForKey:@"longitude"] doubleValue];
    [mapView.contents.markerManager addMarker:marker AtLatLong:markerPosition];
    
    //[self setText:name forMarker: marker];
    marker.data = markerData; //[NSstring stringID stringValue];
        
    [marker release];
}

// TODO Bild nur einmal am startup laden und resizen
-(void) addBusMarkerAt:(NSDictionary*) busData andID:(int)ID {

    NSLog(@"iconType: %@", [self getIconTypeFromZoomLevel:[mapView.contents zoom]]);
    
    NSDictionary *busLineImages = [busImages objectForKey: [busData objectForKey:@"route_number"]];
    NSString *imageName = [busLineImages objectForKey:[self getIconTypeFromZoomLevel:[mapView.contents zoom]]];
    UIImage *image = [UIImage imageNamed:imageName];
    
    NSLog(@"imageName: %@", imageName);
        
    double longitude = [[busData objectForKey:@"longitude"] doubleValue];
    double latitude = [[busData objectForKey:@"latitude"] doubleValue];    
    CLLocationCoordinate2D busCoordinate;
    busCoordinate.longitude = longitude;
    busCoordinate.latitude  = latitude;
    
    // set marker
    RMMarker *marker = [[RMMarker alloc] initWithUIImage:image anchorPoint:CGPointMake(0.5, 0.5)];
    marker.data = busData;
    [mapView.contents.markerManager addMarker:marker AtLatLong:busCoordinate];
        
    [busMarkers addObject:marker];// forKey:[NSNumber numberWithInt:ID]];
    
    [marker release];
}

- (void) beforeMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
    
    NSLog(@"zoom Factor: %f", [mapView.contents zoom]);
}

- (void) afterMapZoom:(RMMapView *)map byFactor:(float)zoomFactor near:(CGPoint)center {
    NSLog(@"afterZoom: ");
    [self repaintMarkers];
}

-(void) repaintMarkers{
    BOOL repaint = NO;
    UIImage *stop_image = nil;
    
    NSLog(@"currentZoomLevel %f ", currentZoomLevel);
    
    if(([mapView.contents zoom] < 13) && (currentZoomLevel > 13)) {
        repaint = YES;
        stop_image = stopImage_tiny;
    }
    if(([mapView.contents zoom] < 14.5) && ([mapView.contents zoom] > 13.0) && ((currentZoomLevel > 14.5) || (currentZoomLevel < 13.0))) {
        repaint = YES;
        stop_image = stopImage_small;
    }
    if(([mapView.contents zoom] < 15.5) && ([mapView.contents zoom] > 14.5) && ((currentZoomLevel < 14.5) || (currentZoomLevel > 15.5))) {
        repaint = YES;
        stop_image = stopImage_middle;
    }
    if(([mapView.contents zoom] > 15.5) && (currentZoomLevel < 15.5)) {
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
}



// return either tiny, small, middle oder large
// evtl noch konstanten draus
- (NSString*)getIconTypeFromZoomLevel:(float)zoomLevel {
    NSString *iconType = [[[NSString alloc] init] autorelease];
    if(zoomLevel <= 13) {
        iconType = @"tiny";
    }
    if((zoomLevel <= 14.5) && (zoomLevel > 13.0)) {
        iconType = @"small";
    }
    if((zoomLevel <= 15.5) && (zoomLevel > 14.5)) {
        iconType = @"middle";
    }
    if(zoomLevel > 15.5) {
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
    NSLog(@"myPos pressed");
    [mapView moveToLatLong: location];
    [mapView.contents setZoom: 16];
    [self repaintMarkers];
}

// called when new gps fix available
// updates user's position on the map
- (void)gpsUpdate:(NSNotification *)theNotification {
    NSLog(@"new gps fix available");
    double latitude = [[theNotification.userInfo objectForKey:@"la"] doubleValue];
    double longitude = [[theNotification.userInfo objectForKey:@"lo"] doubleValue];
    double precision = [[theNotification.userInfo objectForKey:@"p"] doubleValue];
    
    location.longitude = latitude;
    location.latitude  = longitude;
    
    [locationMarker updatePosition:location withAccurnacy:precision];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
