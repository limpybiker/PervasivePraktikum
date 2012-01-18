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

@class Reachability;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UINavigationController *navigationController;
    GCDAsyncUdpSocket *udpSocket;
    GCDAsyncSocket *asyncSocket;
    
    Reachability* internetReachable;
    Reachability* hostReachable;
}

@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) Reachability *hostReachable;

- (void) deregisterFromServer;
- (void) registerOnServer;
- (void) checkNetworkStatus:(NSNotification *)notice;


@end
