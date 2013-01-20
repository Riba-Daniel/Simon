//
//  SIUIApplication_SearchesTests.m
//  Simon
//
//  Created by Derek Clarkson on 4/01/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/NSObject+Simon.h>
#import <Simon/SIUIApplication.h>
#import <Simon/SIUIApplication+Searches.h>
#import <Simon/SISyntaxException.h>
#import <Simon/SIUINotAnInputViewException.h>
#import <Simon/SIUINotFoundException.h>
#import <Simon/SIUITooManyFoundException.h>
#import "AbstractTestWithControlsOnView.h"
#import <dNodi/DNNode.h>

@interface SIUIApplication_SearchesTests : AbstractTestWithControlsOnView

@end

@implementation SIUIApplication_SearchesTests

-(void) testViewWithQueryFindsButton {
	id<DNNode> button = (id<DNNode>)[[SIUIApplication application] viewWithQuery:@"//UIRoundedRectButton/UIButtonLabel[text='Button 1']/.."];
	GHAssertEqualStrings(button.dnName, @"UIRoundedRectButton", @"Search bar not returned");
}

-(void) testViewWithQueryThrowsIfNotFound {
	@try {
		[[SIUIApplication application] viewWithQuery:@"//abc"];
		GHFail(@"Exception not thrown");
	}
	@catch (SIUINotFoundException *exception) {
		GHAssertEqualStrings(exception.name, NSStringFromClass([SIUINotFoundException class]), @"Incorrect domain");
		GHAssertEqualStrings(exception.reason, @"Path //abc failed to find anything.", @"Reason incorrect");
	}
}

-(void) testViewWithQueryThrowsIfTooManyFound {
	@try {
		[[SIUIApplication application] viewWithQuery:@"//UISegmentLabel"];
		GHFail(@"Exception not thrown");
	}
	@catch (SIUITooManyFoundException *exception) {
		GHAssertEqualStrings(exception.name, NSStringFromClass([SIUITooManyFoundException class]), @"Incorrect domain");
		GHAssertEqualStrings(exception.reason, @"Path //UISegmentLabel should return one view only, got 2 instead.", @"Reason incorrect");
	}
}

-(void) testViewWithQueryThrowsIfInvalidQuery {
	@try {
		[[SIUIApplication application] viewWithQuery:@"//["];
		GHFail(@"Exception not thrown");
	}
	@catch (SISyntaxException *exception) {
		GHAssertEqualStrings(exception.name, NSStringFromClass([SISyntaxException class]), nil);
		GHAssertEqualStrings(exception.reason, @"Query appears to be incomplete.", nil);
	}
}

-(void) testFindViewsWithQueryFindsAllButtons {
	[[SIUIApplication application] logUITree];
	NSArray *controls = [[SIUIApplication application] viewsWithQuery:@"//UITableViewCell"];
	GHAssertTrue([controls count] > 0, @"Nothing returned");
	for (UIView *view in controls) {
		GHAssertTrue([view isKindOfClass:[UITableViewCell class]], @"Non-table view cell found");
	}
}

-(void) findViewWithQueryTimeoutFindsView {
	id<DNNode> button = (id<DNNode>)[[SIUIApplication application] viewWithQuery:@"//UIRoundedRectButton/UIButtonLabel[text='Button 1']/.." timeout:1.0];
	GHAssertEqualStrings(button.dnName, @"UIRoundedRectButton", @"Search bar not returned");
}

-(void) testViewWithQueryTimeoutThrowsIfNotFound {
	@try {
		[[SIUIApplication application] viewWithQuery:@"//abc" timeout:1.0];
		GHFail(@"Exception not thrown");
	}
	@catch (SIUINotFoundException *exception) {
		GHAssertEqualStrings(exception.name, NSStringFromClass([SIUINotFoundException class]), @"Incorrect domain");
		GHAssertEqualStrings(exception.reason, @"Path //abc failed to find anything.", @"Reason incorrect");
	}
}

-(void) testViewWithQueryTimeoutThrowsIfTooManyFound {
	@try {
		[[SIUIApplication application] viewWithQuery:@"//UISegmentLabel" timeout:1.0];
		GHFail(@"Exception not thrown");
	}
	@catch (SIUITooManyFoundException *exception) {
		GHAssertEqualStrings(exception.name, NSStringFromClass([SIUITooManyFoundException class]), @"Incorrect domain");
		GHAssertEqualStrings(exception.reason, @"Path //UISegmentLabel should return one view only, got 2 instead.", @"Reason incorrect");
	}
}

-(void) testViewWithTagFindsButton {
	UIButton *button = (UIButton *)[[SIUIApplication application] viewWithTag:1];
	GHAssertEqualStrings(button.titleLabel.text, @"Button 1", nil);
}

-(void) testViewWithTagThrowsIfNotFound {
	@try {
		[[SIUIApplication application] viewWithTag:-999];
		GHFail(@"Exception not thrown");
	}
	@catch (SIUINotFoundException *exception) {
		GHAssertEqualStrings(exception.name, NSStringFromClass([SIUINotFoundException class]), @"Incorrect domain");
		GHAssertEqualStrings(exception.reason, @"Path //[tag='-999'] failed to find anything.", @"Reason incorrect");
	}
}

-(void) testIsViewPresentReturnsYes {
	GHAssertTrue([[SIUIApplication application] isViewPresent:@"//UIRoundedRectButton/UIButtonLabel[text='Button 1']/.."], @"Should have returned YES");
}

-(void) testIsViewPresentReturnsNo {
	GHAssertFalse([[SIUIApplication application] isViewPresent:@"xxxx"], @"Should have returned NO");
}

-(void) testIsViewPresentViewReturnsYes {
	UIView *view = nil;
	GHAssertTrue([[SIUIApplication application] isViewPresent:@"//UIRoundedRectButton/UIButtonLabel[text='Button 1']/.." view:&view], @"Should have returned YES");
	GHAssertNotNil(view, nil);
	GHAssertEqualStrings(((UIButton *) view).titleLabel.text, @"Button 1", nil);
}

-(void) testIsViewPresentViewReturnsNo {
	UIView *view = nil;
	GHAssertFalse([[SIUIApplication application] isViewPresent:@"xxxx" view:&view], @"Should have returned NO");
	GHAssertNil(view, nil);
}

-(void) testButtonWithLableFindsButton {
	UIButton *button = [[SIUIApplication application] buttonWithLabel:@"Button 1"];
	GHAssertEqualStrings(button.titleLabel.text, @"Button 1", nil);
}

@end
