//
//  SettingsViewController.m
//  PassauBusApp
//
//  Created by Macbook on 10.11.11.
//  Copyright (c) 2011 Josef Kinseher All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController
@synthesize settingsSwitchUseGPS;
@synthesize settingsSwitchShowStops;
@synthesize settingsSwitchShowRoute4;
@synthesize settingsSwitchShowRoute8;

NSString * settingsUseGPS = @"true";
NSString * settingsShowStops = @"true";

NSString * settingsShowRoute4 = @"true";
NSString * settingsShowRoute8 = @"true";


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



- (void) loadSettings{
    
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
    
    NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    settingsUseGPS = [[savedStock objectForKey:@"useGPS"] copy];
    settingsShowStops = [[savedStock objectForKey:@"showStops"] copy];
    settingsShowRoute4 = [[savedStock objectForKey:@"showRoute4"] copy];
    settingsShowRoute8 = [[savedStock objectForKey:@"showRoute8"] copy];
    
    [savedStock release];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Einstellungen";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    
    // TODO model muss check beim app start machen... vars in model
    [self loadSettings];
    
    // update settings view
    
    [settingsSwitchUseGPS setOn:NO];
    if([settingsUseGPS isEqualToString:@"true"]) [settingsSwitchUseGPS setOn:YES];
    [settingsSwitchShowStops setOn:NO];
    if([settingsShowStops isEqualToString:@"true"]) [settingsSwitchShowStops setOn:YES];
 
    [settingsSwitchShowRoute4 setOn:NO];
    if([settingsShowRoute4 isEqualToString:@"true"]) [settingsSwitchShowRoute4 setOn:YES];
    [settingsSwitchShowRoute8 setOn:NO];
    if([settingsShowRoute8 isEqualToString:@"true"]) [settingsSwitchShowRoute8 setOn:YES];
    
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
    
    [data setObject:settingsUseGPS forKey:@"useGPS"];
    [data setObject:settingsShowStops forKey:@"showStops"];
    [data setObject:settingsShowRoute4 forKey:@"showRoute4"];
    [data setObject:settingsShowRoute8 forKey:@"showRoute8"];
    
    [data writeToFile:plistPath atomically:YES];
    [data release];
}




// settings buttons handling


- (IBAction)settingsClickSwitchUseGPS:(id)sender {
    settingsUseGPS = @"false";
    if(settingsSwitchUseGPS.isOn) settingsUseGPS = @"true";
    [self saveSettings];
}



- (IBAction)settingsClickSwitchShowStops:(id)sender {
    settingsShowStops = @"false";
    if(settingsSwitchShowStops.isOn) settingsShowStops = @"true";
    [self saveSettings];
}

- (IBAction)settingsClickSwitchShowRoute4:(id)sender {
    settingsShowRoute4 = @"false";
    if(settingsSwitchShowRoute4.isOn) settingsShowRoute4 = @"true";
    [self saveSettings];
}


- (IBAction)settingsClickSwitchShowRoute8:(id)sender {
    settingsShowRoute8 = @"false";
    if(settingsSwitchShowRoute8.isOn) settingsShowRoute8 = @"true";
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
