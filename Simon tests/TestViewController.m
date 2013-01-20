//
//  TestViewController.m
//  Simon
//
//  Created by Derek Clarkson on 7/02/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "TestViewController.h"
#import <dUsefulStuff/DCCommon.h>

@interface TestViewController (_private)
-(void) updateDisplayLabel:(NSString *) text;
@end

@implementation TestViewController

@synthesize button1 = _button1;
@synthesize button2 = _button2;
@synthesize button3 = _button3;
@synthesize waitForItButton = _waitForItButton;
@synthesize tabBar = _tabBar;
@synthesize tapableLabel = _tapableLabel;
@synthesize displayLabel = _displayLabel;
@synthesize textField = _textField;
@synthesize phoneNumberField = _phoneNumberField;
@synthesize tappedButton = _tappedButton;
@synthesize tappedTabBarItem = _tappedTabBarItem;
@synthesize slider = _slider;
@synthesize tableView = _tableView;
@synthesize selectedRow = _selectedRow;
@synthesize gestureRecognizerTapped = _gestureRecognizerTapped;
@synthesize startDragTime = _startDragTime;
@synthesize endDragTime = _endDragTime;

- (void)dealloc {
   self.button1 = nil;
   self.button2 = nil;
   self.button3 = nil;
   self.waitForItButton = nil;
   self.tabBar = nil;
   self.slider = nil;
   self.tableView = nil;
   self.tapableLabel = nil;
   self.displayLabel = nil;
   self.startDragTime = nil;
   self.endDragTime = nil;
	self.textField = nil;
	self.phoneNumberField = nil;
   [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return YES;
}

#pragma mark - Interface events

- (IBAction)buttonTapped:(id)sender {
   UIView *button = sender;
   DC_LOG(@"Button tapped: %i", button.tag);
   self.tappedButton = button.tag;
}

- (IBAction)waitForItTapped:(id)sender {
   [self performSelector:@selector(updateDisplayLabel:) withObject:@"Clicked!" afterDelay:1.5];
}

-(void) updateDisplayLabel:(NSString *) text {
   self.displayLabel.text = text;
}


- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
   DC_LOG(@"Tab bar item tapped: %i", item.tag);
   self.tappedTabBarItem = item.tag;
}

-(void) detectedRecognizerTap:(UIGestureRecognizer *)gestureRecognizer {
   DC_LOG(@"Gesture recognizer tapped");
   self.gestureRecognizerTapped = YES;
}

#pragma mark - View

-(void) viewDidLoad {
   [super viewDidLoad];
   
   // Add a gesture recogniser
   UIGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detectedRecognizerTap:)] autorelease];
   gr.enabled = YES;
   [self.tapableLabel addGestureRecognizer:gr];
	_selectedRow = -1;
}

#pragma mark - Table methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"X"];
	if (cell == nil) { 
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"X"] autorelease];
	}
   cell.textLabel.text = [NSString stringWithFormat:@"Cell %i", indexPath.row];
	cell.tag = indexPath.row;
   
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   DC_LOG(@"Row %i selected", indexPath.row);
   _selectedRow = indexPath.row;
}

#pragma mark - Scroll View delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
   self.startDragTime = [NSDate date];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
   self.endDragTime = [NSDate date];
}

- (NSTimeInterval) dragDuration {
   return [self.endDragTime timeIntervalSinceDate:self.startDragTime];
}

-(void) deselectRow {
	NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
	if (selectedRow != nil) {
		DC_LOG(@"Deselecting row %i", selectedRow.row);
		[self.tableView deselectRowAtIndexPath:selectedRow animated:NO];
		_selectedRow = -1;
	}
}


- (void)viewDidUnload {
    [self setButton3:nil];
    [super viewDidUnload];
}
@end
