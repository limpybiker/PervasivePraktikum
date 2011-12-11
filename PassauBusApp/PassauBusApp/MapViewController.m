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


@implementation MapViewController

@synthesize settingsController;

const int MARKER_TOUCH_SIZE = 44;
const int ROUTE_LINE_WIDTH = 5;
const int NUMBER_OF_BUSES = 15;

CLLocationCoordinate2D location;

NSMutableDictionary *busMarkers;
NSMutableSet *stopMarkers;

//TODO: GLOBALE ID's in PList für alle bus stops


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // get notified when new gps data available
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gpsUpdate:) name:@"NewGpsFix" object:nil]; 
        // get notified when updated bus positions available
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(busUpdate:) name:@"NewBusData" object:nil]; 
        
        busMarkers = [[NSMutableDictionary alloc] init];
        stopMarkers = [[NSMutableSet alloc] init];
        
        
        /*UIImage *image = [UIImage imageNamed:@"bus_stop_icon.png"];
        int iconSize = 40;
        //resize image
        CGSize size = CGSizeMake(MARKER_TOUCH_SIZE, MARKER_TOUCH_SIZE);
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(MARKER_TOUCH_SIZE/2-iconSize/2, MARKER_TOUCH_SIZE/2-iconSize/2,iconSize,iconSize)];
        UIImage* resizeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [image release];
        
        busmarker = [[RMMarker alloc] initWithUIImage:resizeImage anchorPoint:CGPointMake(0.5, 0.5)];
        [mapView.contents.markerManager addMarker:busmarker ];*/

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
    
    
    self.navigationItem.title = @"Passau Bus App";
    self.navigationItem.rightBarButtonItem = settingsButton;
    self.navigationItem.leftBarButtonItem = myPosButton;
        
    //this button is shown to go back to this view
    self.navigationItem.backBarButtonItem =
        [[[UIBarButtonItem alloc] initWithTitle:@"Zurück" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
    
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
    
    // adjust zoom levels
    [mapView.contents setMaxZoom:18];
    [mapView.contents setMinZoom:10];
    
    
    // initialize location marker
    locationMarker = [[CMCurrentLocationMarker alloc] initWithContents:[mapView contents] accurancy:0];    
    
    if (![CLLocationManager locationServicesEnabled])
        NSLog(@"GPS is not enabled");
    
    [self drawRoute:@"route_4_to_achleiten.plist":[UIColor brownColor]];
    [self drawRoute:@"route_4_to_hochstein.plist":[UIColor brownColor]];

    [self drawRoute:@"route_8_to_koenigschalding.plist":[UIColor magentaColor]];
    [self drawRoute:@"route_8_to_kohlbruck.plist":[UIColor magentaColor]];
    
    [self setBusStops:@"route_4_to_achleiten_stops.plist"];
    [self setBusStops:@"route_4_to_hochstein_stops.plist"];
    
    [self setBusStops:@"route_8_to_koenigschalding_stops.plist"];
    [self setBusStops:@"route_8_to_kohlbruck_stops.plist"];

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
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    NSArray *coordinates = [dictionary objectForKey:@"stops"];    
    
    CLLocationCoordinate2D markerCoordinate;
    
    for(int i=0; i<[coordinates count]; i++) {
        NSArray *position = [coordinates objectAtIndex:i];
        
        markerCoordinate.longitude = [[position objectAtIndex:2] doubleValue];
        markerCoordinate.latitude  = [[position objectAtIndex:1] doubleValue];

        [self addBusStopMarkerAt:markerCoordinate andName:[position objectAtIndex:0] andSize: 20 andID:i];
    }
}

-(void) updateBusPosition:(int) busID {
  
    /*NSDictionary *busData = [bus_locations objectForKey:[NSNumber numberWithInt:busID]];
    
    NSString *route_destination = [busData objectForKey:@"route_destination"];
    int route_number = [[busData objectForKey:@"route_number"] intValue];
    double longitude = [[busData objectForKey:@"longitude"] doubleValue];
    double latitude = [[busData objectForKey:@"latitude"] doubleValue];
    
    CLLocationCoordinate2D positionCoordinate;
    positionCoordinate.longitude = longitude;
    positionCoordinate.latitude  = latitude;
    */

}
                           
                           
- (void) setText: (NSString*)text forMarker: (RMMarker*) marker {
    CGSize textSize = [text sizeWithFont: [RMMarker defaultFont]]; 
    CGPoint position = CGPointMake(  -(textSize.width/2 - marker.bounds.size.width/2), -textSize.height );
    [marker changeLabelUsingText: text position: position ];    
}

// update navigation bar on tap on item
- (void) tapOnMarker: (RMMarker*) marker onMap: (RMMapView*) map {
    NSLog(@"Name: %@", marker.data);
    self.navigationItem.title = (NSString *)marker.data;
    //[marker addAnnotationViewWithTitle:@"name"];

}


// reset navigation bar on double Tap on Map
- (void) doubleTapOnMap: (RMMapView*) map At: (CGPoint) point {
    self.navigationItem.title = @"Passau Bus App";
}


// TODO Bild nur einmal am startup laden und resizen
-(void) addBusStopMarkerAt:(CLLocationCoordinate2D) markerPosition andName:(NSString*)name andSize:(int)iconSize andID:(int)ID {

    UIImage *image = [UIImage imageNamed:@"bus_stop_icon.png"];
    
    //resize image
    CGSize size = CGSizeMake(MARKER_TOUCH_SIZE, MARKER_TOUCH_SIZE);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(MARKER_TOUCH_SIZE/2-iconSize/2, MARKER_TOUCH_SIZE/2-iconSize/2,iconSize,iconSize)];
    UIImage* resizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image release];

    // set marker
    RMMarker *marker = [[RMMarker alloc] initWithUIImage:resizeImage anchorPoint:CGPointMake(0.5, 0.5)];
    [stopMarkers addObject:marker];
    [mapView.contents.markerManager addMarker:marker AtLatLong:markerPosition];
    
    //[self setText:name forMarker: marker];
    marker.data = name;
        
    [marker release];
}

// TODO Bild nur einmal am startup laden und resizen
-(void) addBusMarkerAt:(NSDictionary*) busData andSize:(int)iconSize andID:(int)ID {
    
    UIImage *image = [UIImage imageNamed:@"bus_4_icon40x40.png"];
    
    //resize image
    CGSize size = CGSizeMake(MARKER_TOUCH_SIZE, MARKER_TOUCH_SIZE);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(MARKER_TOUCH_SIZE/2-iconSize/2, MARKER_TOUCH_SIZE/2-iconSize/2,iconSize,iconSize)];
    UIImage* resizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image release];
    
    //NSString *route_destination = [busData objectForKey:@"route_destination"];
    //int route_number = [[busData objectForKey:@"route_number"] intValue];
    double longitude = [[busData objectForKey:@"longitude"] doubleValue];
    double latitude = [[busData objectForKey:@"latitude"] doubleValue];    
    CLLocationCoordinate2D busCoordinate;
    busCoordinate.longitude = longitude;
    busCoordinate.latitude  = latitude;
    
    // set marker
    RMMarker *marker = [[RMMarker alloc] initWithUIImage:resizeImage anchorPoint:CGPointMake(0.5, 0.5)];
    [busMarkers setObject:marker forKey:[NSNumber numberWithInt:ID]];
    [mapView.contents.markerManager addMarker:marker AtLatLong:busCoordinate];
    
    //[self setText:name forMarker: marker];
    marker.data = busData;
    
    [marker release];
}

-(void) updateBusMarkerPosition:(NSDictionary*) busData andID:(int)ID {
    RMMarker *marker = [busMarkers objectForKey:[NSNumber numberWithInt:ID]];
    marker.data = busData;
    
    double longitude = [[busData objectForKey:@"longitude"] doubleValue];
    double latitude = [[busData objectForKey:@"latitude"] doubleValue];    
    CLLocationCoordinate2D busCoordinate;
    busCoordinate.longitude = longitude;
    busCoordinate.latitude  = latitude;
    
    [mapView.contents.markerManager removeMarker:marker];
    [mapView.contents.markerManager addMarker:marker AtLatLong:busCoordinate];
}

- (void) beforeMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
    
    NSLog(@"zoom Factor: %f", [mapView.contents zoom]);
}

- (void) afterMapZoom:(RMMapView *)map byFactor:(float)zoomFactor near:(CGPoint)center {
    NSLog(@"afterZoom: ");
    
    int iconSize = MARKER_TOUCH_SIZE - (MARKER_TOUCH_SIZE - [mapView.contents zoom]*2.5);


    if([mapView.contents zoom] < 14.5) {
        iconSize = MARKER_TOUCH_SIZE - (MARKER_TOUCH_SIZE - [mapView.contents zoom]*1.5);
        NSLog(@"case 1");
    }
    if(([mapView.contents zoom] < 15.5) && ([mapView.contents zoom] > 14.5)) {
        iconSize = MARKER_TOUCH_SIZE - (MARKER_TOUCH_SIZE - [mapView.contents zoom]*2);
        NSLog(@"case 2");
    }
    if(([mapView.contents zoom] < 16.5) && ([mapView.contents zoom] > 15.5)) {
        iconSize = MARKER_TOUCH_SIZE - (MARKER_TOUCH_SIZE - [mapView.contents zoom]*2.5);
        NSLog(@"case 3");
    }
    
    NSLog(@"iconSize %i", iconSize);
    
    UIImage *image = [UIImage imageNamed:@"bus_stop_icon.png"];
    
    //resize image
    CGSize size = CGSizeMake(MARKER_TOUCH_SIZE, MARKER_TOUCH_SIZE);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(MARKER_TOUCH_SIZE/2-iconSize/2, MARKER_TOUCH_SIZE/2-iconSize/2,iconSize,iconSize)];
    UIImage* resizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image release];
    
    for(int i= 0; i<[[stopMarkers allObjects] count]; i++) {
        [[[stopMarkers allObjects] objectAtIndex:i] replaceUIImage:resizeImage anchorPoint:CGPointMake(0.5, 0.5)];
    }
    
    //TODO bus icons je nach linie laden für resize
    
}


-(void)doSettings:(id)sender {
    NSLog(@"settings pressed");
    settingsController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];    
    [self.navigationController pushViewController:settingsController animated:YES];    
}

// updates the bus positions on the map
- (void)busUpdate:(NSNotification *)theNotification {
    NSLog(@"new bus position available");
    
    
    //BUS ID NEEDS TO BE DETERMINED OR POSTED FROM THE SERVER
    int bus_id = [[theNotification.userInfo objectForKey:@"bus_id"] intValue];
    //int bus_id = 1;
    
    // andID noch aus SIGNATUR raus und in data rein
    
    if([busMarkers objectForKey:[NSNumber numberWithInt:bus_id]] == nil) {
        //add new marker
        [self addBusMarkerAt:theNotification.userInfo andSize:40 andID:bus_id];
    } else {
        //change marker position
        [self updateBusMarkerPosition:theNotification.userInfo andID:bus_id];
    }
}


-(void)doMyPos:(id)sender {
    NSLog(@"myPos pressed");
    [mapView moveToLatLong: location];
    [mapView.contents setZoom: 16];
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
