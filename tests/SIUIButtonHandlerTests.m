//
//  SIUIButtonHandlerTests.m
//  Simon
//
//  Created by Derek Clarkson on 11/03/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "SIUIButtonHandler.h"

@interface SIUIButtonHandlerTests : GHTestCase

@end

@implementation SIUIButtonHandlerTests

-(void) testAttributesReturnedNilWhenNoAttributes {

	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	SIUIButtonHandler *handler = [[[SIUIButtonHandler alloc] init] autorelease];
	handler.view = button;
	
	GHAssertNil([handler kvcAttributes], @"expected a nil");
}

-(void) testAttributesReturnedTag {
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.tag = 1;
	SIUIButtonHandler *handler = [[[SIUIButtonHandler alloc] init] autorelease];
	handler.view = button;
	
	NSDictionary *attributes = [handler kvcAttributes];
	GHAssertEquals([[attributes objectForKey:@"tag"] intValue], 1, @"Incorrect value");
}

-(void) testAttributesContainLabels {
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setTitle:@"Hello" forState:UIControlStateNormal];
	SIUIButtonHandler *handler = [[[SIUIButtonHandler alloc] init] autorelease];
	handler.view = button;
	
	NSDictionary *attributes = [handler kvcAttributes];
	GHAssertEqualStrings([attributes objectForKey:@"titleLabel.text"], @"Hello", @"Incorrect value");
	GHAssertEqualStrings([attributes objectForKey:@"currentTitle"], @"Hello", @"Incorrect value");
}

@end
