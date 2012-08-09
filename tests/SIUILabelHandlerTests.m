//
//  SIUILabelHandlerTests.m
//  Simon
//
//  Created by Derek Clarkson on 11/03/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/SIUILabelHandler.h>

@interface SIUILabelHandlerTests : GHTestCase

@end

@implementation SIUILabelHandlerTests

-(void) testAttributesReturnedNilWhenNoAttributes {
	
	UILabel *label = [[[UILabel alloc] init] autorelease];
	SIUILabelHandler *handler = [[[SIUILabelHandler alloc] init] autorelease];
	handler.view = (UIView<DNNode> *) label;
	
	GHAssertNil([handler kvcAttributes], @"expected a nil");
}

-(void) testAttributesReturnedTag {
	
	UILabel *label = [[[UILabel alloc] init] autorelease];
	label.tag = 1;
	SIUILabelHandler *handler = [[[SIUILabelHandler alloc] init] autorelease];
	handler.view = (UIView<DNNode> *) label;
	
	NSDictionary *attributes = [handler kvcAttributes];
	GHAssertEquals([[attributes objectForKey:@"tag"] intValue], 1, @"Incorrect value");
}

-(void) testAttributesContainLabels {
	
	UILabel *label = [[[UILabel alloc] init] autorelease];
	label.text = @"Hello";
	SIUILabelHandler *handler = [[[SIUILabelHandler alloc] init] autorelease];
	handler.view = (UIView<DNNode> *) label;
	
	NSDictionary *attributes = [handler kvcAttributes];
	GHAssertEqualStrings([attributes objectForKey:@"text"], @"Hello", @"Incorrect value");
}

@end
