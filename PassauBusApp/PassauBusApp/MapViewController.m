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


@implementation MapViewController

@synthesize settingsController;

int MARKER_TOUCH_SIZE = 44;
int ROUTE_LINE_WIDTH = 5;

CLLocationCoordinate2D location;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // get notified when new gps data available
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gpsUpdate:) name:@"NewGpsFix" object:nil]; 
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
    location.longitude = 13.46392,0;
    location.latitude  = 48.57351,0;
    [mapView moveToLatLong: location];
    [mapView.contents setZoom: 16];
    
    // adjust zoom levels
    [mapView.contents setMaxZoom:18];
    [mapView.contents setMinZoom:12];
    
    
    // initialize location marker
    locationMarker = [[CMCurrentLocationMarker alloc] initWithContents:[mapView contents] accurancy:0];    
    
    if (![CLLocationManager locationServicesEnabled])
        NSLog(@"GPS is not enabled");
    
    [self drawRoute:@"route_4_to_achleiten.plist":[UIColor brownColor]];
    [self drawRoute:@"route_4_to_hochstein.plist":[UIColor brownColor]];

    [self setBusStops:@"route_4_to_achleiten_stops.plist"];
    [self setBusStops:@"route_4_to_hochstein_stops.plist"];

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

        [self addBusStopMarkerAt:markerCoordinate andName:[position objectAtIndex:0]:20];
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
    self.navigationItem.title = (NSString *)marker.data;
}

// reset navigation bar on double Tap on Map
- (void) doubleTapOnMap: (RMMapView*) map At: (CGPoint) point {
    self.navigationItem.title = @"Passau Bus App";
}


-(void) addBusStopMarkerAt:(CLLocationCoordinate2D) markerPosition andName:(NSString*)name:(int)iconSize {

    UIImage *blueMarkerImage = [UIImage imageNamed:@"bus_stop_icon.png"];
    
    //resize image
    CGSize size = CGSizeMake(MARKER_TOUCH_SIZE, MARKER_TOUCH_SIZE);
    UIGraphicsBeginImageContext(size);
    [blueMarkerImage drawInRect:CGRectMake(MARKER_TOUCH_SIZE/2-iconSize/2, MARKER_TOUCH_SIZE/2-iconSize/2,iconSize,iconSize)];
    UIImage* resizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // set marker
    RMMarker *marker = [[RMMarker alloc] initWithUIImage:resizeImage anchorPoint:CGPointMake(0.5, 0.5)];
    [mapView.contents.markerManager addMarker:marker AtLatLong:markerPosition];
    
    //[self setText:name forMarker: marker];
    marker.data = name;
    
    
    [marker release];
}

- (void) beforeMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
    
    NSLog(@"zoom Factor: %f", [mapView.contents zoom]);
}


-(void)doSettings:(id)sender {
    NSLog(@"settings pressed");
    settingsController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];    
    [self.navigationController pushViewController:settingsController animated:YES];    
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
