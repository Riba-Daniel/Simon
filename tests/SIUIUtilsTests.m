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
#import "SIEnums.h"
#import <dNodi/dNodi.h>

@interface SIUIUtilsTests : GHTestCase {}

@end

@implementation SIUIUtilsTests



-(void) testViewWithQueryFindsSearchBar {
	
	NSError *error = nil;
	UIView<DNNode> *searchBar = [SIUIUtils findViewWithQuery:@"//UISearchBar" error:&error];
	
	GHAssertNotNil(searchBar, @"nil returned, error: %@", [error localizedFailureReason]);
	GHAssertEqualStrings(searchBar.name, @"UISearchBar", @"Search bar not returned");
}

-(void) testViewWithQueryGeneratesErrorIfNotFound {
	
	NSError *error = nil;
	UIView<DNNode> *searchBar = [SIUIUtils findViewWithQuery:@"//abc" error:&error];
	
	GHAssertNil(searchBar, @"Should not have returned an instance");
	GHAssertEquals(error.code, SIUIErrorExpectOnlyOneView, @"Incorrect error.");
}

-(void) testViewWithQueryGeneratesErrorIfTooManyFound {
	
	NSError *error = nil;
	UIView<DNNode> *views = [SIUIUtils findViewWithQuery:@"//UITableViewCell" error:&error];
	
	GHAssertNil(views, @"Should not have returned an instance");
	GHAssertEquals(error.code, SIUIErrorExpectOnlyOneView, @"Incorrect error.");
}

-(void) testUITreeDumpsToConsoleWithoutError {
	[SIUIUtils logUITree]; 
}

-(void) testFindsTableViewRowsUsingViewsWithQuery {

	NSError *error = nil;
	NSArray *controls = [SIUIUtils findViewsWithQuery:@"//UITableViewCell" error:&error];
	GHAssertTrue([controls count] > 0, @"Nothing returned");
	GHAssertNotNil(controls, @"nil returned, error: %@", [error localizedFailureReason]);
	
	for (UIView *view in controls) {
		GHAssertTrue([view isKindOfClass:[UITableViewCell class]], @"Non-table view cell found");
	}
	
}

-(void) testViewWithQueryReturnsErrorIfInvalidXPath {
	
	NSError *error = nil;
	UIView<DNNode> *views = [SIUIUtils findViewWithQuery:@"//[" error:&error];
	
	GHAssertNil(views, @"Should not have returned an instance");
	GHAssertEquals(error.code, DNErrorInvalidNodiExpression, @"Incorrect error.");
}

@end
