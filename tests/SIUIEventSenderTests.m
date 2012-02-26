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
#import "SIUIMainThreadSender.h"
#import "SIUIEventSender.h"
#import "SIUITapGenerator.h"
#import "SIUISwipeGenerator.h"

@interface SIUIEventSenderTests : AbstractTestWithControlsOnView

//-(void) scrollTableViewToIndex:(int) index atScrollPosition:(UITableViewScrollPosition) position;

@end

@implementation SIUIEventSenderTests {
@private
   dispatch_queue_t background;
   dispatch_queue_t main;
}

-(void) setUpClass {
   [super setUpClass];
   background = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
   main = dispatch_get_main_queue();
}

-(void) testBackgroundSenderIsCreated {
   __block SIUIEventSender *sender;
   dispatch_sync(background, ^{
      sender = [[SIUIEventSender sender] retain];
   });
   [sender autorelease];
   GHAssertTrue([sender isKindOfClass: [SIUIBackgroundThreadSender class]], @"Incorrect class");
}

-(void) testMainThreadSenderIsCreated {
   __block SIUIEventSender *sender;
   dispatch_sync(main, ^{
      sender = [[SIUIEventSender sender] retain];
   });
   [sender autorelease];
   GHAssertTrue([sender isKindOfClass: [SIUIMainThreadSender class]], @"Incorrect class");
}

-(void) testSendEvent {
   dispatch_sync(background, ^{
      self.testViewController.tappedButton = 0;
      SIUITapGenerator *tapGenerator = [[[SIUITapGenerator alloc] initWithView:self.testViewController.button1] autorelease];
      [tapGenerator sendEvents];
   });
   [NSThread sleepForTimeInterval:0.1];
   GHAssertEquals(self.testViewController.tappedButton, 1, @"Button not tapped");
}

-(void) testScheduleEventAtTime {
   
   // Note, in this test its quite hard to test the scheduling so we are more looking to see that no errors occured.
   dispatch_sync(background, ^{
      self.testViewController.slider.value = 5.0;
      SIUISwipeGenerator *swipeGenerator = [[[SIUISwipeGenerator alloc] initWithView:self.testViewController.slider] autorelease];
      [swipeGenerator sendEvents];
   });
   [NSThread sleepForTimeInterval:0.5];
   GHAssertEquals(round(self.testViewController.slider.value), 3.0, @"Slider not swiped.");
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
