//
//  TimetableViewController.h
//  PassauBusApp
//
//  Created by Macbook on 10.11.11.
//  Copyright (c) 2011 Josef Kinseher All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimetableViewController : UIViewController {
    UITableView *myTableView;
    NSString *name;

}

@property (nonatomic, retain) IBOutlet UITableView *myTableView;

- (id)initWithString:(NSString *)_name;


@end
