//
//  TimetableViewController.m
//  PassauBusApp
//
//  Created by Macbook on 15.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
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
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //this button is shown to go back to this view
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@"Zurück" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Fahrpläne";
	//return [[self.countries allKeys] objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[schedules objectForKey:name] count];
	//NSString *continent = [self tableView:tableView titleForHeaderInSection:section];
	//return [[self.countries valueForKey:continent] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *Identifier = @"Identifier";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:Identifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 12.0, 260.0, 20.0)];
		label.text = [[[schedules objectForKey:name] allKeys] objectAtIndex:[indexPath row]];
		[cell.contentView addSubview:label];
		[label release];
		
		/*UIImageView *imageView = [[UIImageView alloc] initWithImage:unselectedImage];
		imageView.frame = CGRectMake(5.0, 10.0, 23.0, 23.0);
		[cell.contentView addSubview:imageView];
		imageView.tag = 1;
		[imageView release];*/		
	}
    
	//UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *url = 
    [[[schedules objectForKey:name] allValues] objectAtIndex:[indexPath row]];
    
    WebViewController *webViewController = [[WebViewController alloc] initWithURLString:url];
    [self.navigationController pushViewController:webViewController animated:YES];
}

/*
- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellAccessoryDetailDisclosureButton;
}*/


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {    
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
