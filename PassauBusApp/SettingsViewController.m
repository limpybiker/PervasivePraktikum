//
//  SettingsViewController.m
//  PassauBusApp
//
//  Created by Macbook on 10.11.11.
//  Copyright (c) 2011 Josef Kinseher All rights reserved.
//

#import "SettingsViewController.h"
#import "Settings.h"

@implementation SettingsViewController
@synthesize settingsSwitchUseGPS;
@synthesize settingsSwitchShowStops;
@synthesize settingsSwitchShowRoute4;
@synthesize settingsSwitchShowRoute8;



NSString * _settingsUseGPS;
NSString * _settingsShowStops;

NSString * _settingsShowRoute4;
NSString * _settingsShowRoute8;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    self.navigationItem.title = @"Einstellungen";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    
    // TODO model muss check beim app start machen... vars in model
    //[self loadSettings];
    
    // update settings view
    
    [settingsSwitchUseGPS setOn:NO];
    if([_settingsUseGPS isEqualToString:@"true"]) [settingsSwitchUseGPS setOn:YES];
    [settingsSwitchShowStops setOn:NO];
    if([_settingsShowStops isEqualToString:@"true"]) [settingsSwitchShowStops setOn:YES];
 
    [settingsSwitchShowRoute4 setOn:NO];
    if([_settingsShowRoute4 isEqualToString:@"true"]) [settingsSwitchShowRoute4 setOn:YES];
    [settingsSwitchShowRoute8 setOn:NO];
    if([_settingsShowRoute8 isEqualToString:@"true"]) [settingsSwitchShowRoute8 setOn:YES];
    
}

- (void)viewDidUnload
{
    [self setSettingsSwitchUseGPS:nil];
    [self setSettingsSwitchShowStops:nil];
    [self setSettingsSwitchShowRoute4:nil];
    [self setSettingsSwitchShowRoute8:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void) saveSettings{
    
    // create path for plist
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString * plistPath = [[documentsDirectory stringByAppendingPathComponent:@"AppSettings.plist"] copy];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: plistPath])
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"AppSettings" ofType:@"plist"];
        
        [fileManager copyItemAtPath:bundle toPath: plistPath error:&error]; 
    }
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    [data setObject:_settingsUseGPS forKey:@"useGPS"];
    [data setObject:_settingsShowStops forKey:@"showStops"];
    [data setObject:_settingsShowRoute4 forKey:@"showRoute4"];
    [data setObject:_settingsShowRoute8 forKey:@"showRoute8"];
    
    [data writeToFile:plistPath atomically:YES];
    [data release];
}




// settings buttons handling


- (IBAction)settingsClickSwitchUseGPS:(id)sender {
    _settingsUseGPS = @"false";
    if(settingsSwitchUseGPS.isOn) _settingsUseGPS = @"true";
    [self saveSettings];
}



- (IBAction)settingsClickSwitchShowStops:(id)sender {
    _settingsShowStops = @"false";
    if(settingsSwitchShowStops.isOn) _settingsShowStops = @"true";
    [self saveSettings];
}

- (IBAction)settingsClickSwitchShowRoute4:(id)sender {
    _settingsShowRoute4 = @"false";
    if(settingsSwitchShowRoute4.isOn) _settingsShowRoute4 = @"true";
    [self saveSettings];
}


- (IBAction)settingsClickSwitchShowRoute8:(id)sender {
    _settingsShowRoute8 = @"false";
    if(settingsSwitchShowRoute8.isOn) _settingsShowRoute8 = @"true";
    [self saveSettings];
}


- (void)dealloc {
    [settingsSwitchUseGPS release];
    [settingsSwitchShowStops release];
    [settingsSwitchShowRoute4 release];
    [settingsSwitchShowRoute8 release];
    [super dealloc];
}
@end
