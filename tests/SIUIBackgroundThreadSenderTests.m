//
//  SIUIEventCannonTests.m
//  Simon
//
//  Created by Derek Clarkson on 22/02/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "AbstractTestWithControlsOnView.h"
#import "SIUIBackgroundThreadSender.h"
#import "SIUIEventSender.h"
#import "SIUITapGenerator.h"

@interface SIUIBackgroundThreadSenderTests : AbstractTestWithControlsOnView

//-(void) scrollTableViewToIndex:(int) index atScrollPosition:(UITableViewScrollPosition) position;

@end

@implementation SIUIBackgroundThreadSenderTests {
@private
   dispatch_queue_t background;
}

-(void) setUpClass {
   [super setUpClass];
   [self setupTestView];
   background = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

-(void) tearDownClass {
   [self removeTestView];
   [super tearDownClass];
}

-(void) testConfirmCorrectSenderIsCreated {
   __block SIUIEventSender *sender;
   dispatch_sync(background, ^{
      sender = [SIUIEventSender sender];
   });
   GHAssertTrue([sender isKindOfClass: [SIUIBackgroundThreadSender class]], @"Incorrect class");
}

-(void) testTapButton1 {
   dispatch_sync(background, ^{
      self.testViewController.tappedButton = 0;
      SIUITapGenerator *tapGenerator = [[[SIUITapGenerator alloc] initWithView:self.testViewController.button1] autorelease];
      [tapGenerator sendEvents];
   });
   [NSThread sleepForTimeInterval:0.1];
   GHAssertEquals(self.testViewController.tappedButton, 1, @"Button not tapped");
}
/*
 -(void) testTapButton2 {
 self.testViewController.tappedButton = 0;
 [self.cannon tapView:self.testViewController.button2];
 [NSThread sleepForTimeInterval:0.1];
 GHAssertEquals(self.testViewController.tappedButton, 2, @"Button not tapped");
 }
 
 -(void) testGestureRecognizerOnLabelTapped {
 self.testViewController.gestureRecognizerTapped = NO;
 [self.cannon tapView:self.testViewController.tapableLabel];
 [NSThread sleepForTimeInterval:0.1];
 GHAssertTrue(self.testViewController.gestureRecognizerTapped, @"gesture recognizer not fired");
 }
 
 -(void) testTableViewTappingRowSelects {
 self.testViewController.selectedRow = 0;
 [self scrollTableViewToIndex:0 atScrollPosition:UITableViewScrollPositionTop];
 [NSThread sleepForTimeInterval:0.1];
 [self.cannon tapView:self.testViewController.tableView];
 [NSThread sleepForTimeInterval:0.1];
 GHAssertEquals(self.testViewController.selectedRow, (NSInteger) 1, @"Row not selected");
 }
 
 #pragma mark - Swipes
 
 -(void) testSwipeSliderRight {
 self.testViewController.slider.value = 5.0;
 [self.cannon swipeView:self.testViewController.slider direction:SIUISwipeDirectionRight distance:100];
 [NSThread sleepForTimeInterval:0.1];
 GHAssertEquals(round(self.testViewController.slider.value), 8.0, @"Slider not swiped.");
 }
 
 -(void) testSliderSwipingLeft {
 self.testViewController.slider.value = 5.0;
 [self.cannon swipeView:self.testViewController.slider direction:SIUISwipeDirectionLeft distance:100];
 [NSThread sleepForTimeInterval:0.1];
 GHAssertEquals(round(self.testViewController.slider.value), 2.0, @"Slider not swiped.");
 }
 
 -(void) testTableViewSwipingUp {
 self.testViewController.selectedRow = 0;
 [self scrollTableViewToIndex:5 atScrollPosition:UITableViewScrollPositionMiddle];
 [self.cannon swipeView:self.testViewController.tableView direction:SIUISwipeDirectionUp distance:100];
 [NSThread sleepForTimeInterval:0.1];
 [self.cannon tapView:self.testViewController.tableView];
 [NSThread sleepForTimeInterval:0.1];
 GHAssertEquals(self.testViewController.selectedRow, (NSInteger)7, @"Swipe or tap failed");
 }
 
 -(void) testTableViewSwipingDown {
 self.testViewController.selectedRow = 0;
 [self scrollTableViewToIndex:5 atScrollPosition:UITableViewScrollPositionMiddle];
 [self.cannon swipeView:self.testViewController.tableView direction:SIUISwipeDirectionDown distance:100];
 [NSThread sleepForTimeInterval:0.1];
 [self.cannon tapView:self.testViewController.tableView];
 [NSThread sleepForTimeInterval:0.1];
 GHAssertEquals(self.testViewController.selectedRow, (NSInteger)3, @"Swipe or tap failed");
 }
 
 #pragma mark - Helpers
 -(void) scrollTableViewToIndex:(int) index atScrollPosition:(UITableViewScrollPosition) position {
 
 // Whatch for the main thread because re-running a test from GHUnit test view runs it on the main thread. Known bug in GHUnit.
 if ([NSThread isMainThread]) {
 [self.testViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:position animated:NO];
 [[NSRunLoop currentRunLoop] runUntilDate: [NSDate date]];
 } else {
 dispatch_queue_t mainQ = dispatch_get_main_queue();
 dispatch_sync(mainQ, ^{
 [self.testViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:position animated:NO];
 [[NSRunLoop currentRunLoop] runUntilDate: [NSDate date]];
 });
 }   
 }
 
 */

@end
