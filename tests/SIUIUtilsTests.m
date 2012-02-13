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

#import "SIUIUtils.h"
#import "UIView+Simon.h"
#import "UIView+Simon.h"
#import "SIConstants.h"
#import <dNodi/dNodi.h>
#import "AbstractTestWithControlsOnView.h"
#import "SIUITooManyFoundException.h"
#import "SIUINotFoundException.h"
#import "SISyntaxException.h"

@interface SIUIUtilsTests : AbstractTestWithControlsOnView {}

@end

@implementation SIUIUtilsTests

-(void) setUpClass {
   [super setUpClass];
   [self setupTestView];
}

-(void) tearDownClass {
   [self removeTestView];
   [super tearDownClass];
}

#pragma mark - findViewWithQuery

-(void) testViewWithQueryFindsButton {
   SIPrintCurrentWindowTree();
	UIView<DNNode> *button = [SIUIUtils findViewWithQuery:@"//UIRoundedRectButton/UIButtonLabel[@text='Button 1']/.."];
	GHAssertEqualStrings(button.name, @"UIRoundedRectButton", @"Search bar not returned");
}

-(void) testViewWithQueryThrowsIfNotFound {
	@try {
      [SIUIUtils findViewWithQuery:@"//abc"];
      GHFail(@"Exception not thrown");
   } 
	@catch (SIUINotFoundException *exception) {
      GHAssertEqualStrings(exception.name, NSStringFromClass([SIUINotFoundException class]), @"Incorrect domain");
      GHAssertEqualStrings(exception.reason, @"Path //abc failed to find anything.", @"Reason incorrect");
   }
}

-(void) testViewWithQueryThrowsIfTooManyFound {
	@try {
      [SIUIUtils findViewWithQuery:@"//UISegmentLabel"];
      GHFail(@"Exception not thrown");
   }
   @catch (SIUITooManyFoundException *exception) {
      GHAssertEqualStrings(exception.name, NSStringFromClass([SIUITooManyFoundException class]), @"Incorrect domain");
      GHAssertEqualStrings(exception.reason, @"Path //UISegmentLabel should return one view only, got 2 instead.", @"Reason incorrect");
   }
}

-(void) testViewWithQueryThrowsIfInvalidXPath {
	@try {
      [SIUIUtils findViewWithQuery:@"//["];
      GHFail(@"Exception not thrown");
   }
   @catch (SISyntaxException *exception) {
      GHAssertEqualStrings(exception.name, NSStringFromClass([SISyntaxException class]), @"Incorrect domain");
      GHAssertEqualStrings(exception.reason, @"Cannot go from a // to a [ at character index 2", @"Reason incorrect");
   }
}

#pragma mark - findViewsWithQuery

-(void) testFindViewsWithQueryFindsAllButtons {
	NSArray *controls = [SIUIUtils findViewsWithQuery:@"//UITableViewCell"];
	GHAssertTrue([controls count] > 0, @"Nothing returned");
	for (UIView *view in controls) {
		GHAssertTrue([view isKindOfClass:[UITableViewCell class]], @"Non-table view cell found");
	}
}

#pragma mark - logUITree

-(void) testLogUITreeDumpsToConsoleWithoutError {
	[SIUIUtils logUITree]; 
}

#pragma mark - taps

-(void) testTapViewWithQueryTapsButton1 {
   self.testViewController.tappedButton = 0;
   [SIUIUtils tapViewWithQuery:@"//UIRoundedRectButton[@titleLabel.text='Button 1']"];
   GHAssertEquals(self.testViewController.tappedButton, 1, @"Button not tapped");
}

-(void) testTapViewWithQueryTapsButton2 {
   self.testViewController.tappedButton = 0;
   [SIUIUtils tapViewWithQuery:@"//UIRoundedRectButton[@titleLabel.text='Button 2']"];
   GHAssertEquals(self.testViewController.tappedButton, 2, @"Button not tapped");
}

-(void) testTapTabBarButtonWithLabelTapsButton1 {
   self.testViewController.tappedTabBarItem = 0;
   [SIUIUtils tapTabBarButtonWithLabel:@"Favorites"];
   GHAssertEquals(self.testViewController.tappedTabBarItem, 1, @"Tab bar item not tapped");
}

-(void) testTapTabBarButtonWithLabelTapsButton2 {
   self.testViewController.tappedTabBarItem = 0;
   [SIUIUtils tapTabBarButtonWithLabel:@"More"];
   GHAssertEquals(self.testViewController.tappedTabBarItem, 2, @"Tab bar item not tapped");
}


-(void) testTapButtonWithLabel {
   self.testViewController.tappedButton = 0;
   [SIUIUtils tapButtonWithLabel:@"Button 1"];
   GHAssertEquals(self.testViewController.tappedButton, 1, @"Button not tapped");
}


@end
