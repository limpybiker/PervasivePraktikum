//
//  TimetableViewController.m
//  PassauBusApp
//
//  Created by Macbook on 10.11.11.
//  Copyright (c) 2011 Josef Kinseher All rights reserved.
//

#import "TimetableViewController.h"
#import "WebViewController.h"

@implementation TimetableViewController

@synthesize myTableView;

NSMutableDictionary *schedules;


- (id)initWithString:(NSString *)_name {
    self = [super init];
    if (self) {
        name = [_name retain];
        
        //load schedules
        NSString *filePath = [[NSBundle mainBundle] bundlePath];
        NSString *finalPath = [filePath stringByAppendingPathComponent:@"BusStopSchedules.plist"];
        
        schedules = [[NSMutableDictionary dictionaryWithContentsOfFile:finalPath] retain];
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //this button is shown to go back to this view
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@"Zurück" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
    
    self.navigationItem.title = name;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Fahrpläne";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[schedules objectForKey:name] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *Identifier = @"Identifier";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 12.0, 260.0, 24.0)];
		label.text = [[[schedules objectForKey:name] allKeys] objectAtIndex:[indexPath row]];
        [label setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:label];
		[label release];	
	}
    	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *url = 
    [[[schedules objectForKey:name] allValues] objectAtIndex:[indexPath row]];
    
    WebViewController *webViewController = [[WebViewController alloc] initWithURLString:url andName:[[[schedules objectForKey:name] allKeys]objectAtIndex:[indexPath row]]];
    [self.navigationController pushViewController:webViewController animated:YES];
    [webViewController release];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {    
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [myTableView deselectRowAtIndexPath:[myTableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
}


@end
