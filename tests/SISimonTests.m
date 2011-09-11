//
//  SISimonTests.m
//  Simon
//
//  Created by Derek Clarkson on 30/08/11.
//  Copyright (c) 2011. All rights reserved.
//

#import "SiSimon.h"
#import "SIRuntime.h"
#import "SIStepMapping.h"
#import "AbstractTestWithControlsOnView.h"

@interface SISimonTests : AbstractTestWithControlsOnView {}
-(void) dummyMethod;

@end

@implementation SISimonTests


SIMapStepToSelector(@"abc", dummyMethod);
-(void) testSIMapStepToSelector {
	
	// First find the mapping.
	SIRuntime *runtime = [[[SIRuntime alloc] init] autorelease];
	NSArray *methods = [runtime allMappingMethodsInRuntime];

	for (SIStepMapping *mapping in methods) {
		if (mapping.targetClass == [self class]
			 && mapping.selector == @selector(dummyMethod)) {
			// good so exit.
			return;
		}
	}
	GHFail(@"Mapping has not worked");	
}

-(void) testSIFindViewFindsASingleControl {
	NSError *error = nil;
	UIView *foundView = SIFindView(@"/UIView", &error);
	GHAssertNotNil(foundView, @"Nil returned, error: %@", [error localizedFailureReason]);
	GHAssertEqualObjects(foundView, view, @"Returned view is not a match");
}

-(void) testSIFindViewReturnsErrors {
	NSError *error = nil;
	UIView *foundView = SIFindView(@"/xxx", &error);
	GHAssertNil(foundView, @"Should not have returned an object");
	GHAssertNotNil(error, @"Error should not be nil");
}

-(void) testSIFindViewsFindsASingleControl {
	NSError *error = nil;
	NSArray *foundViews = SIFindViews(@"/UIView", &error);
	GHAssertNotNil(foundViews, @"Nil returned, error: %@", [error localizedFailureReason]);
	GHAssertEqualObjects([foundViews objectAtIndex:0], view, @"Returned view is not a match");
}

-(void) testSITapControl {
	NSError *error = nil;
	SITapControl(@"/UIView/UIRoundedRectButton", &error);
	GHAssertTrue(tapped, @"Tapped flag not set. Control tapping may not have worked");
}

// Helpers
-(void) dummyMethod {}

@end
