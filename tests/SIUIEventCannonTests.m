//
//  SIUIEventCannonTests.m
//  Simon
//
//  Created by Derek Clarkson on 22/02/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "SIUIEventCannon.h"
#import "AbstractTestWithControlsOnView.h"

@interface SIUIEventCannonTests : AbstractTestWithControlsOnView
@property (nonatomic, retain) SIUIEventCannon *cannon;
-(void) scrollTableViewToIndex:(int) index atScrollPosition:(UITableViewScrollPosition) position;
@end

@implementation SIUIEventCannonTests

@synthesize cannon = cannon_;

-(void) setUpClass {
   [super setUpClass];
   [self setupTestView];
   self.cannon = [[[SIUIEventCannon alloc] init] autorelease];
}

-(void) tearDownClass {
   [self removeTestView];
   self.cannon = nil;
   [super tearDownClass];
}

#pragma mark - taps

-(void) testTapButton1 {
   self.testViewController.tappedButton = 0;
   [self.cannon tapView:self.testViewController.button1];
   GHAssertEquals(self.testViewController.tappedButton, 1, @"Button not tapped");
}

-(void) testTapButton2 {
   self.testViewController.tappedButton = 0;
   [self.cannon tapView:self.testViewController.button2];
   GHAssertEquals(self.testViewController.tappedButton, 2, @"Button not tapped");
}

-(void) testGestureRecognizerOnLabelTapped {
   self.testViewController.gestureRecognizerTapped = NO;
	[self.cannon tapView:self.testViewController.tapableLabel];
   GHAssertTrue(self.testViewController.gestureRecognizerTapped, @"gesture recognizer not fired");
}

-(void) testTableViewTappingRowSelects {
   self.testViewController.selectedRow = 0;
   [self scrollTableViewToIndex:0 atScrollPosition:UITableViewScrollPositionTop];
   [self.cannon tapView:self.testViewController.tableView];
   GHAssertEquals(self.testViewController.selectedRow, (NSInteger) 1, @"Row not selected");
}

#pragma mark - Swipes

-(void) testSwipeSliderRight {
   self.testViewController.slider.value = 5.0;
   [self.cannon swipeView:self.testViewController.slider direction:SIUISwipeDirectionRight distance:100];
   GHAssertEquals(round(self.testViewController.slider.value), 8.0, @"Slider not swiped.");
}

-(void) testSliderSwipingLeft {
   self.testViewController.slider.value = 5.0;
   [self.cannon swipeView:self.testViewController.slider direction:SIUISwipeDirectionLeft distance:100];
   GHAssertEquals(round(self.testViewController.slider.value), 2.0, @"Slider not swiped.");
}

-(void) testTableViewSwipingUp {
   self.testViewController.selectedRow = 0;
   [self scrollTableViewToIndex:5 atScrollPosition:UITableViewScrollPositionMiddle];
   [self.cannon swipeView:self.testViewController.tableView direction:SIUISwipeDirectionUp distance:100];
   [self.cannon tapView:self.testViewController.tableView];
	GHAssertEquals(self.testViewController.selectedRow, (NSInteger)3, @"Swipe or tap failed");
}

-(void) testTableViewSwipingDown {
   self.testViewController.selectedRow = 0;
   [self scrollTableViewToIndex:5 atScrollPosition:UITableViewScrollPositionMiddle];
   [self.cannon swipeView:self.testViewController.tableView direction:SIUISwipeDirectionDown distance:100];
   [self.cannon tapView:self.testViewController.tableView];
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



@end
