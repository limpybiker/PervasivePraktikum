//
//  WebViewController.h
//  PassauBusApp
//
//  Created by Macbook on 16.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate> {
    
    UIWebView *webView;
    NSString *urlString;
    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, retain) IBOutlet UIWebView *myWebView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

//@property (nonatomic, retain) NSString *name;

- (id)initWithURLString:(NSString *)_url;

@end
