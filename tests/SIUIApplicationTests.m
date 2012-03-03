//
//  SIUIUtils.m
//  Simon
//
//  Created by Derek Clarkson on 7/23/11.
//  Copyright 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>
#import <UIKit/UIKit.h>

#import "SIUIApplication.h"
#import "UIView+Simon.h"
#import "UIView+Simon.h"
#import "SIConstants.h"
#import <dNodi/dNodi.h>
#import "AbstractTestWithControlsOnView.h"
#import "SIUITooManyFoundException.h"
#import "SIUINotFoundException.h"
#import "SISyntaxException.h"
#import "SIUIException.h"

@interface SIUIApplicationTests : AbstractTestWithControlsOnView

@end

@implementation SIUIApplicationTests

#pragma mark - findViewWithQuery

-(void) testViewWithQueryFindsButton {
	UIView<DNNode> *button = [[SIUIApplication application] findViewWithQuery:@"//UIRoundedRectButton/UIButtonLabel[@text='Button 1']/.."];
	GHAssertEqualStrings(button.name, @"UIRoundedRectButton", @"Search bar not returned");
}

-(void) testViewWithQueryThrowsIfNotFound {
	@try {
      [[SIUIApplication application] findViewWithQuery:@"//abc"];
      GHFail(@"Exception not thrown");
   } 
	@catch (SIUINotFoundException *exception) {
      GHAssertEqualStrings(exception.name, NSStringFromClass([SIUINotFoundException class]), @"Incorrect domain");
      GHAssertEqualStrings(exception.reason, @"Path //abc failed to find anything.", @"Reason incorrect");
   }
}

-(void) testViewWithQueryThrowsIfTooManyFound {
	@try {
      [[SIUIApplication application] findViewWithQuery:@"//UISegmentLabel"];
      GHFail(@"Exception not thrown");
   }
   @catch (SIUITooManyFoundException *exception) {
      GHAssertEqualStrings(exception.name, NSStringFromClass([SIUITooManyFoundException class]), @"Incorrect domain");
      GHAssertEqualStrings(exception.reason, @"Path //UISegmentLabel should return one view only, got 2 instead.", @"Reason incorrect");
   }
}

-(void) testViewWithQueryThrowsIfInvalidXPath {
	@try {
      [[SIUIApplication application] findViewWithQuery:@"//["];
      GHFail(@"Exception not thrown");
   }
   @catch (SISyntaxException *exception) {
      GHAssertEqualStrings(exception.name, NSStringFromClass([SISyntaxException class]), @"Incorrect domain");
      GHAssertEqualStrings(exception.reason, @"Cannot go from a // to a [ at character index 2", @"Reason incorrect");
   }
}

#pragma mark - findViewsWithQuery

-(void) testFindViewsWithQueryFindsAllButtons {
   [[SIUIApplication application] logUITree];
	NSArray *controls = [[SIUIApplication application] findViewsWithQuery:@"//UITableViewCell"];
	GHAssertTrue([controls count] > 0, @"Nothing returned");
	for (UIView *view in controls) {
		GHAssertTrue([view isKindOfClass:[UITableViewCell class]], @"Non-table view cell found");
	}
}

#pragma mark - logUITree

-(void) testLogUITreeDumpsToConsoleWithoutError {
	[[SIUIApplication application] logUITree]; 
}

#pragma mark - taps

-(void) testTapViewWithQueryTapsButton1 {
   self.testViewController.tappedButton = 0;
   [[SIUIApplication application] tapViewWithQuery:@"//UIRoundedRectButton[@titleLabel.text='Button 1']"];
   GHAssertEquals(self.testViewController.tappedButton, 1, @"Button not tapped");
}

-(void) testTapViewWithQueryTapsButton2 {
   self.testViewController.tappedButton = 0;
   [[SIUIApplication application] tapViewWithQuery:@"//UIRoundedRectButton[@titleLabel.text='Button 2']"];
   GHAssertEquals(self.testViewController.tappedButton, 2, @"Button not tapped");
}

-(void) testTapTabBarButtonWithLabelTapsButton1 {
   self.testViewController.tappedTabBarItem = 0;
   [[SIUIApplication application] tapTabBarButtonWithLabel:@"Favorites"];
   GHAssertEquals(self.testViewController.tappedTabBarItem, 1, @"Tab bar item not tapped");
}

-(void) testTapTabBarButtonWithLabelTapsButton2 {
   self.testViewController.tappedTabBarItem = 0;
   [[SIUIApplication application] tapTabBarButtonWithLabel:@"More"];
   GHAssertEquals(self.testViewController.tappedTabBarItem, 2, @"Tab bar item not tapped");
}

-(void) testTapButtonWithLabel {
   self.testViewController.tappedButton = 0;
   [[SIUIApplication application] tapButtonWithLabel:@"Button 1"];
   GHAssertEquals(self.testViewController.tappedButton, 1, @"Button not tapped");
}

-(void) testTapButtonWithLabelAndWait {

   self.testViewController.tappedButton = 0;
   
   NSDate *before = [NSDate date];
   [[SIUIApplication application] tapButtonWithLabel:@"Button 1" andWait:1.0];
   NSTimeInterval diff = [before timeIntervalSinceNow];
   
   GHAssertEquals(self.testViewController.tappedButton, 1, @"Button not tapped");
   GHAssertLessThan(diff, -1.0, @"Not enough time passed");
}

#pragma mark - Swipes

-(void) testSwipeSlider {
   self.testViewController.slider.value = 5;
   [[SIUIApplication application] swipeViewWithQuery:@"//UISlider" inDirection:SIUISwipeDirectionRight forDistance: 80];
   
   GHAssertEquals(round(self.testViewController.slider.value), 8.0, @"Slider not swiped.");
}

-(void) testTableViewSwipingDown {
   [[SIUIApplication application] logUITree];
   self.testViewController.selectedRow = 0;
   [self scrollTableViewToIndex:5 atScrollPosition:UITableViewScrollPositionMiddle];

   [[SIUIApplication application] swipeViewWithQuery:@"//UIView//UITableView" inDirection:SIUISwipeDirectionDown forDistance:80];
   
   [NSThread sleepForTimeInterval:0.1];
   [[SIUIApplication application] tapViewWithQuery:@"//UIView//UITableView"];
   
   [NSThread sleepForTimeInterval:0.1];
   GHAssertEquals(self.testViewController.selectedRow, (NSInteger)3, @"Swipe or tap failed");
}


#pragma mark - Other

-(void) testPauseFor {
   NSDate *before = [NSDate date];
   [[SIUIApplication application] pauseFor:0.5];
   NSTimeInterval diff = [before timeIntervalSinceNow];
   GHAssertLessThan(diff, -0.5, @"Not enough time passed");
}

-(void) testWaitFor {
   
   self.testViewController.displayLabel.text = @"...";
   [[NSRunLoop mainRunLoop] runUntilDate:[NSDate date]];

   [[SIUIApplication application] tapButtonWithLabel:@"Wait for it!"];
   GHAssertEqualStrings(self.testViewController.displayLabel.text, @"...", @"Label should not be updated yet");
   UIView *label = [[SIUIApplication application] waitForViewWithQuery:@"//UILabel[@text='Clicked!']" retryInterval:0.5 maxRetries:5];
   GHAssertNotNil(label, @"Nothing returned");
   GHAssertEqualStrings(self.testViewController.displayLabel.text, @"Clicked!", @"Button should have updated by now");
}

-(void) testWaitForExitsOnOtherException {
	@try {
      [[SIUIApplication application] waitForViewWithQuery:@"//[" retryInterval:0.5 maxRetries:5];
      GHFail(@"Exception not thrown");
   }
   @catch (SISyntaxException *exception) {
      // Good
   }
}

-(void) testWaitForExceedsRetryCount {
   
   self.testViewController.displayLabel.text = @"...";
   [[NSRunLoop mainRunLoop] runUntilDate:[NSDate date]];
	
   @try {
      [[SIUIApplication application] waitForViewWithQuery:@"//UILabel[@text='Wait for it!']" retryInterval:0.5 maxRetries:5];
      GHFail(@"Exception not thrown");
   }
   @catch (SIUIException *exception) {
      // Good
   }
}


@end
