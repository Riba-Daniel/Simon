//
//  SIStoryInAppViewController.m
//  Simon
//
//  Created by Derek Clarkson on 9/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import "SIStoryReportTableViewController.h"
#import <dUSefulStuff/DCCommon.h>
#import "SIStory.h"
#import "NSString+Simon.h"
#import "SIStorySource.h"
#import <dUsefulStuff/DCDialogs.h>

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

#pragma mark - View lifecycle

-(void) viewDidLoad {
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.backgroundView = nil;
	self.tableView.separatorColor = [UIColor grayColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
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
	cell.textLabel.text = story.title;
	cell.detailTextLabel.text = [NSString stringStatusWithStory:story];
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	switch (story.status) {
		case SIStoryStatusError:
			cell.detailTextLabel.textColor = [UIColor redColor];
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			break;
		case SIStoryStatusNotMapped:
			cell.textLabel.textColor = [UIColor lightGrayColor];
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			break;
		default:
			// Do nothing.
			break;
	}
	
	DC_LOG(@"returning %@ cell", story.title);
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
	
	CGFloat lineHeight = [UIFont systemFontOfSize:14.0f].lineHeight + 4.0f;
	UIView *headerLine = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, lineHeight)] autorelease];
	
	label.frame = CGRectMake(50, 0, 50, lineHeight);
	label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	[headerLine addSubview:label];
	
	return headerLine;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	SIStorySource *source = [self.storySources objectAtIndex:indexPath.section];
	SIStory *story = [source.stories objectAtIndex:indexPath.row];
	
	switch (story.status) {
			
		case SIStoryStatusError:
			[DCDialogs displayMessage:story.error.localizedFailureReason];
			break;
			
		case SIStoryStatusNotMapped: {
			NSMutableString *message = [NSMutableString string];
			[story.steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				SIStep *step = (SIStep *) obj;
				NSString *selector = @"";
				if (step.stepMapping.selector != nil) {
					selector = [NSString stringWithFormat:@"%@ -> %@::%@\n",
									step.command,
									NSStringFromClass(step.stepMapping.targetClass),
					NSStringFromSelector(step.stepMapping.selector)];
				}
				[message appendString:selector];
			}];
			[DCDialogs displayMessage:message];
			
			break;
		}
			
		default:
			break;
	}
	
}


@end
