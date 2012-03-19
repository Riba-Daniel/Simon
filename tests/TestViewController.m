//
//  TestViewController.m
//  Simon
//
//  Created by Derek Clarkson on 7/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController (_private)
-(void) updateDisplayLabel:(NSString *) text;
@end

@implementation TestViewController

@synthesize button1 = button1_;
@synthesize button2 = button2_;
@synthesize waitForItButton = waitForItButton_;
@synthesize tabBar = tabBar_;
@synthesize tapableLabel = tapableLabel_;
@synthesize displayLabel = displayLabel_;
@synthesize textField = textField_;
@synthesize tappedButton = tappedButton_;
@synthesize tappedTabBarItem = tappedTabBarItem_;
@synthesize slider = slider_;
@synthesize tableView = tableView_;
@synthesize selectedRow = selectedRow_;
@synthesize gestureRecognizerTapped = gestureRecognizerTapped_;
@synthesize startDragTime = startDragTime_;
@synthesize endDragTime = endDragTime_;

- (void)dealloc {
   self.button1 = nil;
   self.button2 = nil;
   self.waitForItButton = nil;
   self.tabBar = nil;
   self.slider = nil;
   self.tableView = nil;
   self.tapableLabel = nil;
   self.displayLabel = nil;
   self.startDragTime = nil;
   self.endDragTime = nil;
	self.textField = nil;
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
   
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   DC_LOG(@"Row %i selected", indexPath.row);
   self.selectedRow = indexPath.row;
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

@end
