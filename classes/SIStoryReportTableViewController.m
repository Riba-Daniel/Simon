//
//  SIStoryInAppViewController.m
//  Simon
//
//  Created by Derek Clarkson on 9/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import "SIStoryReportTableViewController.h"
#import "SIStory.h"
#import "NSString+Simon.h"
#import "SIStorySource.h"
#import <dUsefulStuff/DCDialogs.h>
#import "SIStoryDetailsTableViewController.h"

@interface SIStoryReportTableViewController (_private)
-(void) rerunStories;
@end

@implementation SIStoryReportTableViewController

@synthesize storySources = storySources_;
@synthesize mappings = mappings_;

-(void) dealloc {
	DC_LOG(@"Deallocing");
	self.view = nil;
	self.storySources = nil;
	self.mappings = nil;
	[super dealloc];
}

#pragma mark - UIView methods

-(void) viewDidLoad {
	// This should stop extra divider lines from appearing down the screen when
	// there are not enough cells.
	UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)] autorelease];
	footerView.backgroundColor = [UIColor clearColor];
	[self.tableView setTableFooterView:footerView];
}


#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.storySources count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	DC_LOG(@"There are %i stories in section %i", [((SIStorySource *)[self.storySources objectAtIndex:section]).stories count], section);
	return [((SIStorySource *)[self.storySources objectAtIndex:section]).stories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Story cell"];
	if (cell == nil) { 
		// Create one.
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Story cell"] autorelease];
	}
	
	// Get the source and story.
	NSArray *stories = ((SIStorySource *)[self.storySources objectAtIndex:indexPath.section]).stories;
	SIStory *story = (SIStory *)[stories objectAtIndex:indexPath.row];
   
   // Setup the cell.
	cell.textLabel.text = story.title;
	cell.detailTextLabel.text = [NSString stringStatusWithStory:story];
   cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	switch (story.status) {
		case SIStoryStatusError:
			cell.textLabel.textColor = [UIColor redColor];
			cell.detailTextLabel.textColor = [UIColor blackColor];
			break;
		case SIStoryStatusNotMapped:
			cell.textLabel.textColor = [UIColor lightGrayColor];
			cell.detailTextLabel.textColor = [UIColor lightGrayColor];
			break;
		default:
			cell.textLabel.textColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
			cell.detailTextLabel.textColor = [UIColor blackColor];
			break;
	}
	
	DC_LOG(@"returning %@ cell", story.title);
	return cell;
}

#pragma mark - Table view delegate

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [((SIStorySource *)[self.storySources objectAtIndex:section]).source lastPathComponent];
}
 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	SIStoryDetailsTableViewController *details = [[[SIStoryDetailsTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
	
   details.source = [self.storySources objectAtIndex:indexPath.section];
	details.story = (SIStory *)[details.source.stories objectAtIndex:indexPath.row];
	details.navigationItem.title = details.story.title;
	
	UIBarButtonItem *rerunButton = [[UIBarButtonItem alloc] initWithTitle:@"Run" 
																						 style:UIBarButtonItemStylePlain 
																						target:details 
																						action:@selector(rerunStory)];
	
	details.navigationItem.rightBarButtonItem = rerunButton;
	[rerunButton release];

   DC_LOG(@"Loading details for story %@", details.story.title);
	[self.navigationController pushViewController:details animated:YES];
}

#pragma mark - Running stories

-(void) rerunStories {
	DC_LOG(@"Rerunning stories");
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:SI_RERUN_GROUP_NOTIFICATION object:nil]];
}

#pragma mark - View rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   return YES;
}

@end
