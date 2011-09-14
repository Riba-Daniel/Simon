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


@interface SIUIViewHandlerTests : AbstractTestWithControlsOnView {}
@end

@implementation SIUIViewHandlerTests

-(void) testSynthesizingATap {
	SIUIViewHandler *handler  = [[[SIUIViewHandler alloc] init] autorelease];
	handler.view = view;
	[handler tap];
	GHAssertTrue(tapped, @"Tap did not occur as expected");
}

@end
