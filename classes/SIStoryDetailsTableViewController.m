//
//  SIStoryDetailsTableViewController.m
//  Simon
//
//  Created by Derek Clarkson on 24/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import "SIStoryDetailsTableViewController.h"

@implementation SIStoryDetailsTableViewController

@synthesize source = source_;
@synthesize story = story_;

-(void) dealloc {
	self.story = nil;
	self.source = nil;
	[super dealloc];
}

#pragma mark - UIView methods

-(void) viewDidLoad {
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.backgroundView = nil;
	self.tableView.separatorColor = [UIColor lightGrayColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

#pragma mark - Delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 45;
}

#pragma mark - Data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReportCell"];
	
	if (cell == nil) { 
		// Create one.
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"ReportCell"] autorelease];
		
		//cell.textLabel.bounds
	}
	
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"Story file";
			cell.detailTextLabel.text = [self.source.source lastPathComponent];
			break;
		case 1:
			cell.textLabel.text = @"Error";
			cell.detailTextLabel.text = [self.story.error localizedDescription];
			break;
		case 2:
			cell.textLabel.text = @"Error details";
			cell.detailTextLabel.text = [self.story.error localizedFailureReason];
			break;
		default:
			break;
	}
	
	return cell;
}
@end
