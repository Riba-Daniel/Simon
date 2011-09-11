//
//  StoryImplementations.m
//  Simon
//
//  Created by Derek Clarkson on 7/23/11.
//  Copyright 2011. All rights reserved.
//
#import "SISimon.h"
#import <GHUnitIOS/GHUnit.h>

@interface StoryImplementations : GHTestCase {
}
@end

@implementation StoryImplementations

SIMapStepToSelector(@"Given the interface is up", givenTheInterfaceIsUp)
-(void) givenTheInterfaceIsUp {
	NSError *error = nil;
	UILabel *firstViewLabel = (UILabel *) SIFindView(@"UILabel[@text='First View']", &error);
	if (firstViewLabel == nil) {
		GHFail(@"Error: %@", [error localizedFailureReason]);
	}
}

SIMapStepToSelector(@"Then I execute a log UI tree", executePrintUITree)
-(void) executePrintUITree {
	SIPrintCurrentWindowTree();
}

SIMapStepToSelector(@"and it should execute on the main thread", executedOnMainThread)
-(void) executedOnMainThread {
	GHAssertTrue([[NSThread currentThread] isMainThread], @"not on main thread");
}

SIMapStepToSelector(@"then I can switch to the second view", clickTheSecondView)
-(void) clickTheSecondView {
	
}

SIMapStepToSelector(@"and see the view", verifyTheViewIsVisible)
-(void) verifyTheViewIsVisible {
}

@end
