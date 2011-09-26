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


@interface SIUIViewHandlerTests : AbstractTestWithControlsOnView {
@private 
	SIUIViewHandler *handler;

}
@end

@implementation SIUIViewHandlerTests

-(void) setUp {
	[super setUp];
	handler  = [[SIUIViewHandler alloc] init];
	handler.view = button;
}

-(void) tearDown {
	DC_DEALLOC(handler);
	[super tearDown];	
}

-(void) testSynthesizingATap {
	[handler tap];
	GHAssertTrue(tapped, @"Tap did not occur as expected");
}

-(void) testName {
	GHAssertEqualStrings(handler.name, @"UIRoundedRectButton", @"Incorrect node returned");
}

-(void) testParentName {
	GHAssertEquals(handler.parentNode, view, @"Incorrect name returned");
}

-(void) testAttributeQueryFailsWithInvalidPropertyName {
	GHAssertThrowsSpecificNamed([handler hasAttribute:@"xyz" withValue:nil], NSException, @"NSUnknownKeyException", @"Handler should have failed request.");
}

-(void) testAttributeQueryMatchesPropertyValue {
	GHAssertTrue([handler hasAttribute:@"alpha" withValue:[NSNumber numberWithInt:1]], @"Handler fails to match attribute data");
}

-(void) testAttributeQueryMatchesNestedPropertyValue {
	GHAssertTrue([handler hasAttribute:@"titleLabel.text" withValue:@"hello"], @"Handler fails to match attribute data");
}

-(void) testSubnodes {
	handler.view = view;
	NSArray *subNodes = handler.subNodes;
	GHAssertEquals([subNodes count], (NSUInteger) 1, @"Should be one sub view");
	GHAssertEquals([subNodes objectAtIndex:0], button, @"Returned node was not the button.");
}

@end
