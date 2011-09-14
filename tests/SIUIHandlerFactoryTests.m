//
//  SIUIHandlerFactoryTests.m
//  Simon
//
//  Created by Derek Clarkson on 13/09/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "SIUIHandlerFactory.h"
#import <dUSefulStuff/DCCommon.h>
#import "SIUIViewHandler.h"
#import "UIView+Simon.h"

@interface SIUIHandlerFactoryTests : GHTestCase {
	@private
	SIUIHandlerFactory *factory;
}

@end

@implementation SIUIHandlerFactoryTests

-(void) setUp {
	factory = [[SIUIHandlerFactory alloc] init];
}

-(void) tearDown {
	DC_DEALLOC(factory);
}

-(void) testCreatesHandler {
	UIView *view = [[[UIView alloc] init] autorelease];
	SIUIViewHandler *handler = [factory createHandlerForView:view];
	GHAssertNotNil(handler, @"Handler not created");
}

-(void) testReturnsSameInstanceForMultipleRequests {
	UIView *view1 = [[[UIView alloc] init] autorelease];
	UIView *view2 = [[[UIView alloc] init] autorelease];
	SIUIViewHandler *handler1 = [factory createHandlerForView:view1];
	SIUIViewHandler *handler2 = [factory createHandlerForView:view2];
	GHAssertEqualObjects(handler1, handler2, @"Different handlers returned when expecting the same instance");
}

@end
