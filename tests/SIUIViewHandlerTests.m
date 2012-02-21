//
//  SIUIActionTests.m
//  Simon
//
//  Created by Derek Clarkson on 10/09/11.
//  Copyright (c) 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "SIUIViewHandler.h"
#import <dUsefulStuff/DCCommon.h>
#import "AbstractTestWithControlsOnView.h"
#import "UIView+Simon.h"


@interface SIUIViewHandlerTests : AbstractTestWithControlsOnView {
@private 
	SIUIViewHandler *handler;
   
}
-(void) scrollTableViewToIndex:(int) index atScrollPosition:(UITableViewScrollPosition) position;
@end

@implementation SIUIViewHandlerTests

-(void) setUpClass {
   [super setUpClass];
   [self setupTestView];
}

-(void) tearDownClass {
   //[self removeTestView];
   [super tearDownClass];
}

-(void) setUp {
	[super setUp];
	handler  = [[SIUIViewHandler alloc] init];
}

-(void) tearDown {
	DC_DEALLOC(handler);
	[super tearDown];	
}

#pragma mark - DNNode test

-(void) testName {
	handler.view = self.testViewController.button1;
	GHAssertEqualStrings(handler.name, @"UIRoundedRectButton", @"Incorrect node returned");
}

-(void) testParentName {
	handler.view = self.testViewController.button1;
	GHAssertEquals(handler.parentNode, self.testViewController.view, @"Incorrect name returned");
}

-(void) testAttributeQueryFailsWithInvalidPropertyName {
	handler.view = self.testViewController.button1;
	GHAssertThrowsSpecificNamed([handler hasAttribute:@"xyz" withValue:nil], NSException, @"NSUnknownKeyException", @"Handler should have failed request.");
}

-(void) testAttributeQueryMatchesPropertyValue {
	handler.view = self.testViewController.button1;
	GHAssertTrue([handler hasAttribute:@"alpha" withValue:[NSNumber numberWithInt:1]], @"Handler fails to match attribute data");
}

-(void) testAttributeQueryMatchesNestedPropertyValue {
	handler.view = self.testViewController.button1;
	GHAssertTrue([handler hasAttribute:@"titleLabel.text" withValue:@"Button 1"], @"Handler fails to match attribute data");
}

-(void) testSubnodes {
   handler.view = self.testViewController.view;
	NSArray *subNodes = handler.subNodes;
	GHAssertEquals([subNodes count], (NSUInteger) 6, @"Should be one sub view");
	GHAssertEquals([subNodes objectAtIndex:0], self.testViewController.button1, @"Returned node was not button 1.");
	GHAssertEquals([subNodes objectAtIndex:1], self.testViewController.button2, @"Returned node was not button 2.");
	GHAssertEquals([subNodes objectAtIndex:2], self.testViewController.tabBar, @"Returned node was not the tab bar.");
	GHAssertEquals([subNodes objectAtIndex:3], self.testViewController.slider, @"Returned node was not the slider.");
	GHAssertEquals([subNodes objectAtIndex:4], self.testViewController.tableView, @"Returned node was not the tableView.");
	GHAssertEquals([subNodes objectAtIndex:5], self.testViewController.tapableLabel, @"Returned node was not the tapable label.");
}

#pragma mark - SIUIAction tests

-(void) testButtonTap {
	
   handler.view = self.testViewController.button1;
	[handler tap];
	
   GHAssertEquals(self.testViewController.tappedButton, 1, @"Tap did not occur as expected");
}

-(void) testGestureRecognizerOnLabelTapped {
	
   self.testViewController.gestureRecognizerTapped = NO;
   handler.view = self.testViewController.tapableLabel;
	[handler tap];
	
   GHAssertTrue(self.testViewController.gestureRecognizerTapped, @"gesture recognizer not fired");
}

-(void) testTableViewTappingRowSelects {
   self.testViewController.selectedRow = 0;
   [self scrollTableViewToIndex:0 atScrollPosition:UITableViewScrollPositionTop];
   
   handler.view = self.testViewController.tableView;
   [handler tap];
	
   DC_LOG(@"Checking state");
   GHAssertEquals(self.testViewController.selectedRow, (NSInteger) 1, @"Row not selected");
}

-(void) testSliderSwipingRight {
   self.testViewController.slider.value = 5.0;
   handler.view = self.testViewController.slider;
   [handler swipe:SIUISwipeDirectionRight distance:100];
	GHAssertEquals(round(self.testViewController.slider.value), round(8), @"Swipe did not occur as expected");
}

-(void) testSliderSwipingLeft {
   self.testViewController.slider.value = 5.0;
   handler.view = self.testViewController.slider;
   [handler swipe:SIUISwipeDirectionLeft distance:100];
	GHAssertEquals(round(self.testViewController.slider.value), round(2), @"Swipe did not occur as expected");
}


-(void) testTableViewSwipingUp {
   handler.view = self.testViewController.slider;
   [handler swipe:SIUISwipeDirectionUp distance:100];
	GHAssertEquals(round(self.testViewController.slider.value), round(1), @"Swipe did not occur as expected");
}

-(void) testTableViewSwipingDown {
   
   self.testViewController.selectedRow = 0;
   [self scrollTableViewToIndex:5 atScrollPosition:UITableViewScrollPositionMiddle];
   
   handler.view = self.testViewController.tableView;
   [handler swipe:SIUISwipeDirectionDown distance:100];
   [NSThread sleepForTimeInterval:0.5];
   [handler tap];
	GHAssertEquals(self.testViewController.selectedRow, (NSInteger)3, @"Row not selected");
}

#pragma mark - Helpers
-(void) scrollTableViewToIndex:(int) index atScrollPosition:(UITableViewScrollPosition) position {
   
   // Whatch for the main thread because re-running a test from GHUnit test view runs it on the main thread.
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
