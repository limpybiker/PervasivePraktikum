//
//  AppDelegate.h
//  PassauBusApp
//
//  Created by Macbook on 10.11.11.
//  Copyright (c) 2011 Josef Kinseher All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UINavigationController *navigationController;
    GCDAsyncUdpSocket *udpSocket;
    GCDAsyncSocket *asyncSocket;
    UIViewController *splashScreeenViewController;
}

@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) UIViewController *splashScreenViewController;


- (void) deregisterFromServer;
- (void) registerOnServer;


@end
