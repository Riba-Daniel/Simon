//
//  SIUIHandlerFactoryTests.m
//  Simon
//
//  Created by Derek Clarkson on 13/09/11.
//  Copyright (c) 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "SIUIViewHandlerFactory.h"
#import <dUSefulStuff/DCCommon.h>
#import "SIUIViewHandler.h"
#import "UIView+Simon.h"

@interface SIUIHandlerFactoryTests : GHTestCase {
	@private
	SIUIViewHandlerFactory *factory;
}

@end

@implementation SIUIHandlerFactoryTests

-(void) setUp {
	factory = [[SIUIViewHandlerFactory alloc] init];
}

-(void) tearDown {
	DC_DEALLOC(factory);
}

-(void) testCreatesHandler {
	UIView *view = [[[UIView alloc] init] autorelease];
	SIUIViewHandler *handler = [factory handlerForView:view];
	GHAssertNotNil(handler, @"Handler not created");
   GHAssertEqualObjects(handler.view, view, @"View not set on handler");
}

-(void) testReturnsSameInstanceForMultipleRequests {
	UIView *view1 = [[[UIView alloc] init] autorelease];
	UIView *view2 = [[[UIView alloc] init] autorelease];
	SIUIViewHandler *handler1 = [factory handlerForView:view1];
	SIUIViewHandler *handler2 = [factory handlerForView:view2];
	GHAssertEqualObjects(handler1, handler2, @"Different handlers returned when expecting the same instance");
}

@end
