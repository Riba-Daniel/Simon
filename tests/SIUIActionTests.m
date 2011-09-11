//
//  SIUIActionTests.m
//  Simon
//
//  Created by Derek Clarkson on 10/09/11.
//  Copyright (c) 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "SIUIAction.h"
#import <dUsefulStuff/DCCommon.h>
#import "AbstractTestWithControlsOnView.h"


@interface SIUIActionTests : AbstractTestWithControlsOnView {}
@end

@implementation SIUIActionTests

-(void) testSynthesizingATap {
	SIUIAction *action  = [[SIUIAction alloc] initWithView:view];
	[action tap];
	GHAssertTrue(tapped, @"Tap did not occur as expected");
}

@end
