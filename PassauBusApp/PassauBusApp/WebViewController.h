//
//  WebViewController.h
//  PassauBusApp
//
//  Created by Macbook on 16.12.11.
//  Copyright (c) 2011 Josef Kinseher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate> {
    NSString *name;
    UIWebView *webView;
    NSString *urlString;
    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, retain) IBOutlet UIWebView *myWebView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

- (id)initWithURLString:(NSString *)_url andName:(NSString*)_name;

@end
