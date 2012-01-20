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

@implementation SIStoryReportTableViewController

@synthesize storySources = storySources_;
@synthesize mappings = mappings_;

-(void) dealloc {
	SI_LOG(@"Deallocing");
	self.view = nil;
	self.storySources = nil;
	self.mappings = nil;
	[super dealloc];
}

#pragma mark - View lifecycle

-(void) viewDidLoad {
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.backgroundView = nil;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
 

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.storySources count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	SI_LOG(@"There are %i stories in section %i", [((SIStorySource *)[self.storySources objectAtIndex:section]).stories count], section);
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
	
	switch (story.status) {
		case SIStoryStatusError:
			cell.detailTextLabel.textColor = [UIColor redColor];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case SIStoryStatusNotMapped:
			cell.textLabel.textColor = [UIColor lightGrayColor];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		default:
         cell.accessoryType = UITableViewCellAccessoryNone;
			break;
	}
	
	SI_LOG(@"returning %@ cell", story.title);
	return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return [UIFont systemFontOfSize:14.0f].lineHeight + 4.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UILabel *label = [[[UILabel alloc] init] autorelease];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor lightGrayColor];
	label.font = [UIFont boldSystemFontOfSize:14.0f];
	label.lineBreakMode = UILineBreakModeHeadTruncation;
	NSString *filename = ((SIStorySource *)[self.storySources objectAtIndex:section]).source;
	label.text = [filename lastPathComponent];

   // Adjust the indent according to the device.
	label.frame = CGRectMake(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? IPAD_HEADER_INDENT : IPHONE_HEADER_INDENT, 0, 0, 0);
   
	// Make sure the label will resize when the table resizes the header.
	label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	UIView *headerLine = [[[UIView alloc] init] autorelease];
	[headerLine addSubview:label];
	
	return headerLine;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	SIStoryDetailsTableViewController *details = [[[SIStoryDetailsTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
   SI_LOG(@"Loading details for story %@", details.story);
	
   details.source = [self.storySources objectAtIndex:indexPath.section];
	details.story = (SIStory *)[details.source.stories objectAtIndex:indexPath.row];
	details.navigationItem.title = details.story.title;

	[self.navigationController pushViewController:details animated:YES];
}

@end
