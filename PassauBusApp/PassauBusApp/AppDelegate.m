//
//  AppDelegate.m
//  PassauBusApp
//
//  Created by Macbook on 10.11.11.
//  Copyright (c) 2011 Josef Kinseher All rights reserved.
//

#import "AppDelegate.h"
#import "MapViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"
#import "JSON.h"


const double REGISTER_TAG = 0;
const double UNREGISTER_TAG = 1;

//TODO konstanten für TCP, UPD, Messages

// BOOL isConnected => status meldungen

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController;
@synthesize splashScreenViewController;


- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    /*
    // Add the splashScreen to the window and display.
    splashScreeenViewController = [[UIViewController alloc] init];
    CGRect frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = [UIImage imageNamed:@"splashScreen@2x.png"];
    
    [splashScreeenViewController.view addSubview:imageView];
    [imageView release];
    
    [self.window addSubview:splashScreeenViewController.view];
    [splashScreeenViewController.view setNeedsDisplay];
    
    
    // Animate splashScreen out
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    splashScreeenViewController.view.alpha = 0.0;
    //tabBarController.view.alpha = 1.0;
    
    [UIView commitAnimations];
    
    // Throw away splashscreen
    [splashScreeenViewController.view removeFromSuperview];
    [splashScreeenViewController release];
    */
    
    // register client on server
    [self registerOnServer];

    
    //set up the udp socket
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

	NSError *error = nil;
	if (![udpSocket bindToPort:4321 error:&error])
        NSLog(@"Error binding: %@", error);
    
	if (![udpSocket beginReceiving:&error])
		NSLog(@"Error receiving: %@", error);
    
    // Override point for customization after application launch.
    UIViewController *rootController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    
    navigationController = [[UINavigationController alloc] initWithRootViewController:rootController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    return YES;    
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

// upd
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
	
    NSString *msg = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
    //NSLog(@" %@", msg);
    
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
    [self deregisterFromServer];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self registerOnServer];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void) registerOnServer {
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    if (![asyncSocket connectToHost:@"192.168.178.26" onPort:1234 withTimeout:-1 error:&error]) {
		NSLog(@"Unable to connect to due to invalid configuration: %@", error);
	}
	else {
		NSLog(@"Connecting... to server %@", error);
        NSString *msg = @"HELLO SERVER";
        NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
        [asyncSocket writeData:data withTimeout:-1 tag:REGISTER_TAG];
        [asyncSocket disconnectAfterWriting];
	}
}

- (void) deregisterFromServer {
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    if (![asyncSocket connectToHost:@"192.168.178.26" onPort:1234 withTimeout:-1 error:&error]) {
		NSLog(@"Unable to connect to due to invalid configuration: %@", error);
	}
	else {
		NSLog(@"Connecting... to server %@", error);
        NSString *msg = @"UNREGISTER";
        NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
        [asyncSocket writeData:data withTimeout:-1 tag:UNREGISTER_TAG];
        [asyncSocket disconnectAfterWriting];
	}
}


@end
