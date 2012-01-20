//
//  SIStoryDetailsTableViewController.m
//  Simon
//
//  Created by Derek Clarkson on 24/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import "SIStoryDetailsTableViewController.h"

@interface SIStoryDetailsTableViewController()
-(NSString *) storyText;
@end

@implementation SIStoryDetailsTableViewController

@synthesize source = source_;
@synthesize story = story_;

-(void) dealloc {
	self.story = nil;
	self.source = nil;
   DC_DEALLOC(font);
	[super dealloc];
}

#pragma mark - UIView methods

-(void) viewDidLoad {
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.backgroundView = nil;
	self.tableView.separatorColor = [UIColor lightGrayColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
   font = [[UIFont systemFontOfSize:14.0f] retain];
}

#pragma mark - Delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   switch (indexPath.section) {
      case 0:
         return [self.story.steps count] * font.lineHeight + 20.0f;
         
      default:
         break;
   }
	return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return font.lineHeight + 4.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
   // No header for the first section.
   if (section == 0) {
      return nil;
   }
   
	UILabel *label = [[[UILabel alloc] init] autorelease];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor lightGrayColor];
	label.font = font;
	label.lineBreakMode = UILineBreakModeHeadTruncation;
   
   label.text = @"Details";
   
   // Adjust the indent according to the device.
	label.frame = CGRectMake(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? IPAD_HEADER_INDENT : IPHONE_HEADER_INDENT, 0, 0, 0);
   
	// Make sure the label will resize when the table resizes the header.
	label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	UIView *headerLine = [[[UIView alloc] init] autorelease];
	[headerLine addSubview:label];
	
	return headerLine;
}

#pragma mark - Data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   switch (section) {
      case 0:
         return 1;
         break;
         
      default:
         return 3;
         break;
   }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReportDetailsCell"];
	
	if (cell == nil) { 
		// Create one.
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"ReportDetailsCell"] autorelease];
		
		//cell.textLabel.bounds
	}
	
   switch (indexPath.section) {
      case 0:
         cell.textLabel.text = @"Story";
         cell.detailTextLabel.text = [self storyText];
         cell.detailTextLabel.numberOfLines = 0;
         break;
         
      default:
         switch (indexPath.row) {
            case 0:
               cell.textLabel.text = @"Story file";
               cell.detailTextLabel.text = [self.source.source lastPathComponent];
               break;
            case 1:
               cell.textLabel.text = @"Error";
               cell.detailTextLabel.text = [self.story.error localizedDescription];
               cell.detailTextLabel.numberOfLines = 0;
               break;
            case 2:
               cell.textLabel.text = @"Error details";
               cell.detailTextLabel.text = [self.story.error localizedFailureReason];
               cell.detailTextLabel.numberOfLines = 0;
               break;
            default:
               break;
         }
   }
	
	return cell;
}

#pragma mark - Private methods

-(NSString *) storyText {
   NSMutableString *text = [NSMutableString string];
   [self.story.steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
      [text appendFormat:@"%@%@", (NSString *) idx > 0 ? @"\n" : @"",((SIStep *)obj).command];
   }];
   return text;
}

@end
