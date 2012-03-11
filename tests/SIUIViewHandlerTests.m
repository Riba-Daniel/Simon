

#import <GHUnitIOS/GHUnit.h>
#import "SIUIViewHandler.h"
#import <dUsefulStuff/DCCommon.h>
#import "AbstractTestWithControlsOnView.h"

@interface SIUIViewHandlerTests : AbstractTestWithControlsOnView {
@private 
	SIUIViewHandler *handler;
}
@end

@implementation SIUIViewHandlerTests

-(void) setUp {
	[super setUp];
	handler  = [[SIUIViewHandler alloc] init];
}

-(void) tearDown {
	DC_DEALLOC(handler);
	[super tearDown];	
}

#pragma mark - DNNode test

-(void) testName {
	handler.view = self.testViewController.button1;
	GHAssertEqualStrings(handler.name, @"UIRoundedRectButton", @"Incorrect node returned");
}

-(void) testParentName {
	handler.view = self.testViewController.button1;
	GHAssertEquals(handler.parentNode, self.testViewController.view, @"Incorrect name returned");
}

-(void) testAttributeQueryFailsWithInvalidPropertyName {
	handler.view = self.testViewController.button1;
	GHAssertThrowsSpecificNamed([handler hasAttribute:@"xyz" withValue:nil], NSException, @"NSUnknownKeyException", @"Handler should have failed request.");
}

-(void) testAttributeQueryMatchesPropertyValue {
	handler.view = self.testViewController.button1;
	GHAssertTrue([handler hasAttribute:@"alpha" withValue:[NSNumber numberWithInt:1]], @"Handler fails to match attribute data");
}

-(void) testAttributeQueryMatchesNestedPropertyValue {
	handler.view = self.testViewController.button1;
	GHAssertTrue([handler hasAttribute:@"titleLabel.text" withValue:@"Button 1"], @"Handler fails to match attribute data");
}

-(void) testSubnodes {
   handler.view = self.testViewController.view;
	NSArray *subNodes = handler.subNodes;
	GHAssertEquals([subNodes count], (NSUInteger) 8, @"Should be one sub view");
	GHAssertEquals([subNodes objectAtIndex:0], self.testViewController.button1, @"Returned node was not button 1.");
	GHAssertEquals([subNodes objectAtIndex:1], self.testViewController.button2, @"Returned node was not button 2.");
	GHAssertEquals([subNodes objectAtIndex:2], self.testViewController.tabBar, @"Returned node was not the tab bar.");
	GHAssertEquals([subNodes objectAtIndex:3], self.testViewController.slider, @"Returned node was not the slider.");
	GHAssertEquals([subNodes objectAtIndex:4], self.testViewController.tableView, @"Returned node was not the tableView.");
	GHAssertEquals([subNodes objectAtIndex:5], self.testViewController.tapableLabel, @"Returned node was not the tapable label.");
	GHAssertEquals([subNodes objectAtIndex:6], self.testViewController.displayLabel, @"Returned node was not the display label.");
	GHAssertEquals([subNodes objectAtIndex:7], self.testViewController.waitForItButton, @"Returned node was not the wait for it button.");
}

-(void) testKvcAttributesReturnsNilWhenNoTag {
   handler.view = [[[UIView alloc] init] autorelease];
	GHAssertNil([handler kvcAttributes], @"Expected a nil");
}

-(void) testKvcAttributesReturnsAttributesWhenTagSet {
   handler.view = [[[UIView alloc] init] autorelease];
	handler.view.tag = 1;
	NSDictionary *attributes = [handler kvcAttributes];
	GHAssertNotNil(attributes, @"Expected aattributes");
	GHAssertEquals([attributes objectForKey:@"tag"], [NSNumber numberWithInt:1], @"Attribute not returned");
}

-(void) testKvcAttributesReturnsAttributesWhenAccessibilityIndentifierSet {
   handler.view = [[[UIView alloc] init] autorelease];
	handler.view.accessibilityIdentifier = @"abc";
	NSDictionary *attributes = [handler kvcAttributes];
	GHAssertNotNil(attributes, @"Expected aattributes");
	GHAssertEquals([attributes objectForKey:@"accessibilityIdentifier"], @"abc", @"Attribute not returned");
}

-(void) testKvcAttributesReturnsAttributesWhenAccessibilityLabelSet {
   handler.view = [[[UIView alloc] init] autorelease];
	handler.view.accessibilityLabel = @"abc";
	NSDictionary *attributes = [handler kvcAttributes];
	GHAssertNotNil(attributes, @"Expected aattributes");
	GHAssertEquals([attributes objectForKey:@"accessibilityLabel"], @"abc", @"Attribute not returned");
}

-(void) testKvcAttributesReturnsAttributesWhenAccessibilityValueSet {
   handler.view = [[[UIView alloc] init] autorelease];
	handler.view.accessibilityValue = @"abc";
	NSDictionary *attributes = [handler kvcAttributes];
	GHAssertNotNil(attributes, @"Expected attributes");
	GHAssertEquals([attributes objectForKey:@"accessibilityValue"], @"abc", @"Attribute not returned");
}

@end
