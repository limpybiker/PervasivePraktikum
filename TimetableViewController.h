//
//  TimetableViewController.h
//  PassauBusApp
//
//  Created by Macbook on 15.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimetableViewController : UIViewController {
    UITableView *myTableView;
    NSString *name;

}

@property (nonatomic, retain) IBOutlet UITableView *myTableView;
//@property (nonatomic, retain) NSString *name;

- (id)initWithString:(NSString *)_name;


@end
