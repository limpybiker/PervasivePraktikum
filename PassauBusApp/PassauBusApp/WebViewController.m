//
//  WebViewController.m
//  PassauBusApp
//
//  Created by Macbook on 16.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

@synthesize myWebView, activityIndicator;

- (id)initWithURLString:(NSString *)_url
{
    self = [super init];
    if (self) {
        urlString = [_url retain];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect bounds = CGRectMake(250, 400, 160, 140);
    
    //add the spinner at the center of the view
    activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];    
    //CGPoint newCenter = (CGPoint) [self center];
    //activityIndicator.center = newCenter;
    [self.view addSubview:activityIndicator];
    
    //start the spinner
    [activityIndicator startAnimating];
    
    webView = [ [ UIWebView alloc ] initWithFrame:bounds];
    webView.delegate = self;
    
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [myWebView loadRequest:requestObj];
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
