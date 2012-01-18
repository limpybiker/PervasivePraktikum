//
//  WebViewController.m
//  PassauBusApp
//
//  Created by Macbook on 16.12.11.
//  Copyright (c) 2011 Josef Kinseher. All rights reserved.
//

#import "WebViewController.h"
#import "Reachability.h"
#import "CustomNotification.h"

@implementation WebViewController

@synthesize myWebView, activityIndicator;

- (id)initWithURLString:(NSString *)_url andName:(NSString*)_name
{
    self = [super init];
    if (self) {
        urlString = [_url retain];
        name = [_name retain];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect bounds = CGRectMake(250, 400, 160, 140);
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size: 14.0];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:name];
    [label sizeToFit];
    [self.navigationItem setTitleView:label];
    [label release];
    
    
    //add the spinner at the center of the view
    activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];    
    CGPoint newCenter = (CGPoint) CGPointMake(160,230);
    activityIndicator.center = newCenter;
    [self.view addSubview:activityIndicator];
    
    //start the spinner
    [activityIndicator startAnimating];
    
    webView = [ [ UIWebView alloc ] initWithFrame:bounds];
    webView.delegate = self;
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];    
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if (internetStatus != NotReachable) {
        //Create a URL object.
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [myWebView loadRequest:requestObj];
    } else {
        CustomNotification *notifier = [[CustomNotification alloc] init];
        [notifier displayCustomNotificationWithText:@"You need an active internet connection to access bus timetables." inView:self.view];
        [notifier release];
        [self.navigationController popViewControllerAnimated:TRUE];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)wView {
    [activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)wView {
    [activityIndicator stopAnimating];
    [activityIndicator removeFromSuperview];
    self.view = wView;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


@end
