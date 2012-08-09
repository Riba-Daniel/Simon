//
//  SIUIHandlerFactoryTests.m
//  Simon
//
//  Created by Derek Clarkson on 13/09/11.
//  Copyright (c) 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/SIUIViewHandlerFactory.h>
#import <dUSefulStuff/DCCommon.h>
#import <Simon/SIUIViewHandler.h>
#import <Simon/SIUIButtonHandler.h>
#import <Simon/SIUILabelHandler.h>
#import <Simon/UIView+Simon.h>

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

-(void) testCreatesViewHandler {
	UIView *view = [[[UIView alloc] init] autorelease];
	SIUIViewHandler *handler = [factory handlerForView:view];
	GHAssertNotNil(handler, @"Handler not created");
   GHAssertEqualObjects(handler.view, view, @"View not set on handler");
}

-(void) testCreatesButtonHandler {
	UIView *view = [UIButton buttonWithType:UIButtonTypeCustom];
	SIUIViewHandler *handler = [factory handlerForView:view];
	GHAssertNotNil(handler, @"Handler not created");
	GHAssertTrue([handler isKindOfClass:[SIUIButtonHandler class]], @"Incorrect handler type");
	GHAssertEqualObjects(handler.view, view, @"View not set on handler");
}

-(void) testCreatesLabelHandler {
	UIView *view = [[[UILabel alloc] init] autorelease];
	SIUIViewHandler *handler = [factory handlerForView:view];
	GHAssertNotNil(handler, @"Handler not created");
	GHAssertTrue([handler isKindOfClass:[SIUILabelHandler class]], @"Incorrect handler type");
	GHAssertEqualObjects(handler.view, view, @"View not set on handler");
}

@end
