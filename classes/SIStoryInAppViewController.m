//
//  SIStoryInAppViewController.m
//  Simon
//
//  Created by Derek Clarkson on 9/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import "SIStoryInAppViewController.h"
#import <dUSefulStuff/DCCommon.h>
#import "SIStory.h"
#import "NSString+Simon.h"

@implementation SIStoryInAppViewController

@synthesize stories = stories_;
@synthesize mappings = mappings_;

-(void) dealloc {
	DC_LOG(@"Deallocing");
	self.view = nil;
	self.stories = nil;
	self.mappings = nil;
	[super dealloc];
}

-(id) initWithSize:(CGSize) size {
	self = [super init];
	if (self) {
		initSize = size;
	}
	return self;
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
	DC_LOG(@"Load view called");
	self.view = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, initSize.width, initSize.height) style:UITableViewStyleGrouped] autorelease];
	
	// Set it up.
	self.tableView.dataSource = self;
	self.tableView.delegate = self;

	// Clear the background.
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.backgroundView = nil;
	self.tableView.separatorColor = [UIColor grayColor];
	
}

-(void) viewDidLoad {
	// Load data
	[self.tableView reloadData];
}

#pragma mark - Table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	DC_LOG(@"There are %i stories", [self.stories count]);
	return [self.stories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Story cell"];
	if (cell == nil) { 
		// Create one.
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Story cell"] autorelease];
	}
	
	SIStory *story = (SIStory *)[self.stories objectAtIndex:indexPath.row];
	cell.textLabel.text = story.title;
	cell.detailTextLabel.text = [NSString stringStatusWithStory:story];
	DC_LOG(@"returning %@ cell", story.title);
	return cell;
}

/*

 if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
 // The device is an iPad running iOS 3.2 or later.
 }
 else {
 // The device is an iPhone or iPod touch.
 }
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

@end
