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

-(void) setUpClass {
   [super setUpClass];
   [self setupTestView];
}

-(void) tearDownClass {
   [self removeTestView];
   [super tearDownClass];
}

-(void) setUp {
	[super setUp];
	handler  = [[SIUIViewHandler alloc] init];
	handler.view = self.testViewController.button1;
}

-(void) tearDown {
	DC_DEALLOC(handler);
	[super tearDown];	
}

#pragma mark - DNNode test

-(void) testName {
	GHAssertEqualStrings(handler.name, @"UIRoundedRectButton", @"Incorrect node returned");
}

-(void) testParentName {
	GHAssertEquals(handler.parentNode, self.testViewController.view, @"Incorrect name returned");
}

-(void) testAttributeQueryFailsWithInvalidPropertyName {
	GHAssertThrowsSpecificNamed([handler hasAttribute:@"xyz" withValue:nil], NSException, @"NSUnknownKeyException", @"Handler should have failed request.");
}

-(void) testAttributeQueryMatchesPropertyValue {
	GHAssertTrue([handler hasAttribute:@"alpha" withValue:[NSNumber numberWithInt:1]], @"Handler fails to match attribute data");
}

-(void) testAttributeQueryMatchesNestedPropertyValue {
	GHAssertTrue([handler hasAttribute:@"titleLabel.text" withValue:@"Button 1"], @"Handler fails to match attribute data");
}

-(void) testSubnodes {
   handler.view = self.testViewController.view;
	NSArray *subNodes = handler.subNodes;
	GHAssertEquals([subNodes count], (NSUInteger) 4, @"Should be one sub view");
	GHAssertEquals([subNodes objectAtIndex:0], self.testViewController.button1, @"Returned node was not button 1.");
	GHAssertEquals([subNodes objectAtIndex:1], self.testViewController.button2, @"Returned node was not button 2.");
	GHAssertEquals([subNodes objectAtIndex:2], self.testViewController.tabBar, @"Returned node was not the tab bar.");
	GHAssertEquals([subNodes objectAtIndex:3], self.testViewController.slider, @"Returned node was not the slider.");
}

#pragma mark - SIUIAction tests

-(void) testSynthesizingATap {
	[handler tap];
	GHAssertEquals(self.testViewController.tappedButton, 1, @"Tap did not occur as expected");
}


-(void) testSwiping {
   handler.view = self.testViewController.slider;
   [handler swipe:SIUISwipeDirectionRight distance:60];
	GHAssertEquals(round(self.testViewController.slider.value), round(8), @"Swipe did not occur as expected");
}

@end
