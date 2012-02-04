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
	UIView *foundView = SIFindView(@"/UIView");
	GHAssertEqualObjects(foundView, view, @"Returned view is not a match");
}

-(void) testSIFindViewReturnsErrors {
   @try {
      SIFindView(@"/xxx");
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      GHAssertEqualStrings(exception.name, SIMON_ERROR_UI_DOMAIN, @"Incorrect domain");
      GHAssertEqualStrings(exception.reason, @"Path /xxx should return one view only, got 0 instead.", @"Reason incorrect");
   }
}

-(void) testSIFindViewsFindsASingleControl {
	NSArray *foundViews = SIFindViews(@"/UIView");
	GHAssertNotNil(foundViews, @"Nil returned");
	GHAssertEqualObjects([foundViews objectAtIndex:0], view, @"Returned view is not a match");
}

-(void) testSITapControl {
	SITapControl(@"/UIView/UIRoundedRectButton");
	GHAssertTrue(tapped, @"Tapped flag not set. Control tapping may not have worked");
}

// Helpers
-(void) dummyMethod {}

@end
