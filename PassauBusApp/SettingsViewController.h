//
//  SettingsViewController.h
//  PassauBusApp
//
//  Created by Macbook on 10.11.11.
//  Copyright (c) 2011 Josef Kinseher All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
@property (retain, nonatomic) IBOutlet UISwitch *settingsSwitchUseGPS;
@property (retain, nonatomic) IBOutlet UISwitch *settingsSwitchShowStops;

@end
