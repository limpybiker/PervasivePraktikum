//
//  AppDelegate.m
//  PassauBusApp
//
//  Created by Macbook on 10.11.11.
//  Copyright (c) 2011 Josef Kinseher All rights reserved.
//

#import "Settings.h"
#import "AppDelegate.h"
#import "MapViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"
#import "JSON.h"
#import "GPSController.h"
#import "Reachability.h"
#import "CustomNotification.h"


const double REGISTER_TAG = 0;
const double UNREGISTER_TAG = 1;

NSString* const SERVER_HOST = @"192.168.178.30";
const int SERVER_PORT = 1234;
const int DEVICE_PORT = 4321;

BOOL isConnectedToServer = NO;


@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController;
@synthesize hostReachable;

- (void) loadSettings{
     
    _settingsUseGPS = @"true";
    _settingsShowStops = @"true";
    _settingsShowRoute4 = @"true";
    _settingsShowRoute8 = @"true";

    
    // obtain path for plist
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString * plistPath = [[documentsDirectory stringByAppendingPathComponent:@"AppSettings.plist"] copy];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: plistPath])
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"AppSettings" ofType:@"plist"];
        
        [fileManager copyItemAtPath:bundle toPath: plistPath error:&error];
    }
    // read settings
    NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];

    _settingsUseGPS = [savedStock objectForKey:@"useGPS"];
    _settingsShowStops = [[savedStock objectForKey:@"showStops"] copy];
    _settingsShowRoute4 = [[savedStock objectForKey:@"showRoute4"] copy];
    _settingsShowRoute8 = [[savedStock objectForKey:@"showRoute8"] copy];
    
    [savedStock release];
    
}


- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UIViewController *rootController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    navigationController = [[UINavigationController alloc] initWithRootViewController:rootController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    
    [self loadSettings];
    
    
    // get notified of internet connection changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    hostReachable = [[Reachability reachabilityWithHostName: SERVER_HOST] retain];
    [hostReachable startNotifier];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];    
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];

    if (internetStatus != NotReachable) {
        // register client on server
        [self registerOnServer];
    } else {
        CustomNotification *notifier = [[CustomNotification alloc] init];
        [notifier displayCustomNotificationWithText:@"You need an active internet connection to track the buses." inView:self.navigationController.view];
        [notifier release];
    }

    //set up the udp socket
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

	NSError *error = nil;
	if (![udpSocket bindToPort:DEVICE_PORT error:&error])
        NSLog(@"Error binding: %@", error);
    
	if (![udpSocket beginReceiving:&error])
		NSLog(@"Error receiving: %@", error);
    

    [[GPSController alloc] init];

    
    return YES;    
}

- (void) checkNetworkStatus:(NSNotification *)notice {
    Reachability *reachability = [notice object];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if (internetStatus == NotReachable) {
        CustomNotification *notifier = [[CustomNotification alloc] init];
        [notifier displayCustomNotificationWithText:@"You need an active internet connection to track buses." inView:self.navigationController.view];
        [notifier release];
    } else {
        if(!isConnectedToServer)
            [self registerOnServer];
    }
}

// tcp
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
	NSLog(@"socket:didConnectToHost:%@ port:%hu", host, port);
}

// tcp
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if(tag == REGISTER_TAG) {
        NSLog(@"successfully registered");
    }
    if(tag == UNREGISTER_TAG) {
        NSLog(@"successfully unregistered");
    }
}

// receive udp data from server and forward it
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
	
    NSString *msg = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSError *error = nil;
	NSDictionary *busData = [parser objectWithString:msg error:&error];
	[parser release];

    if(error == nil) {
        //send out data
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewBusData" object:self userInfo:busData];
    }
} 

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if(isConnectedToServer)
        [self deregisterFromServer];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if(!isConnectedToServer)
        [self registerOnServer];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}


- (void) registerOnServer {
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    if (![asyncSocket connectToHost:SERVER_HOST onPort:SERVER_PORT withTimeout:-1 error:&error]) {
		NSLog(@"Unable to connect to due to invalid configuration: %@", error);
	}
	else {
		NSLog(@"Connecting... to server %@", error);
        NSString *msg = @"HELLO SERVER";
        NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
        [asyncSocket writeData:data withTimeout:-1 tag:REGISTER_TAG];
        [asyncSocket disconnectAfterWriting];
        isConnectedToServer = YES;
	}
}

- (void) deregisterFromServer {
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    if (![asyncSocket connectToHost:SERVER_HOST onPort:SERVER_PORT withTimeout:-1 error:&error]) {
		NSLog(@"Unable to connect to due to invalid configuration: %@", error);
	}
	else {
		NSLog(@"Connecting... to server %@", error);
        NSString *msg = @"UNREGISTER";
        NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
        [asyncSocket writeData:data withTimeout:-1 tag:UNREGISTER_TAG];
        [asyncSocket disconnectAfterWriting];
        isConnectedToServer = NO;
	}
}


@end
