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
	UIView<DNNode> *button = [SIUIUtils findViewWithQuery:@"//UIRoundedRectButton/UIButtonLabel[@text='hello 1']/.."];
	GHAssertEqualStrings(button.name, @"UIRoundedRectButton", @"Search bar not returned");
}

-(void) testViewWithQueryThrowsIfNotFound {
	@try {
      [SIUIUtils findViewWithQuery:@"//abc"];
      GHFail(@"Exception not thrown");
   } 
	@catch (NSException *e) {
      GHAssertEqualStrings(e.name, SIMON_ERROR_UI_DOMAIN, @"Incorrect domain");
      GHAssertEqualStrings(e.reason, @"Path //abc should return one view only, got 0 instead.", @"Reason incorrect");
   }
}

-(void) testViewWithQueryThrowsIfTooManyFound {
	@try {
      [SIUIUtils findViewWithQuery:@"//UISegmentLabel"];
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      GHAssertEqualStrings(exception.name, SIMON_ERROR_UI_DOMAIN, @"Incorrect domain");
      GHAssertEqualStrings(exception.reason, @"Path //UISegmentLabel should return one view only, got 2 instead.", @"Reason incorrect");
   }
}

-(void) testViewWithQueryThrowsIfInvalidXPath {
	@try {
      [SIUIUtils findViewWithQuery:@"//["];
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      GHAssertEqualStrings(exception.name, SIMON_ERROR_UI_DOMAIN, @"Incorrect domain");
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

-(void) testTapButton1 {
   [SIUIUtils tapViewWithQuery:@"//UIRoundedRectButton/UIButtonLabel[@text='hello 1']/.."];
   GHAssertTrue(self.testButton1Tapped, @"Button not tapped");
}

@end
