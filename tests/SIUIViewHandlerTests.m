

#import <GHUnitIOS/GHUnit.h>
#import "SIUIViewHandler.h"
#import <dUsefulStuff/DCCommon.h>
#import "AbstractTestWithControlsOnView.h"
#import <Simon-core/NSObject+Simon.h>

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
	GHAssertEqualStrings(handler.dnName, @"UIRoundedRectButton", @"Incorrect node returned");
}

-(void) testParentName {
	handler.view = self.testViewController.button1;
	GHAssertEquals(handler.dnParentNode, self.testViewController.view, @"Incorrect name returned");
}

-(void) testAttributeQueryFailsWithInvalidPropertyName {
	handler.view = self.testViewController.button1;
	GHAssertThrowsSpecificNamed([handler dnHasAttribute:@"xyz" withValue:nil], NSException, @"NSUnknownKeyException", @"Handler should have failed request.");
}

-(void) testAttributeQueryMatchesPropertyValue {
	handler.view = self.testViewController.button1;
	GHAssertTrue([handler dnHasAttribute:@"alpha" withValue:[NSNumber numberWithInt:1]], @"Handler fails to match attribute data");
}

-(void) testAttributeQueryMatchesNestedPropertyValue {
	handler.view = self.testViewController.button1;
	GHAssertTrue([handler dnHasAttribute:@"titleLabel.text" withValue:@"Button 1"], @"Handler fails to match attribute data");
}

-(void) testSubnodes {
   handler.view = self.testViewController.view;
	NSArray *subNodes = handler.dnSubNodes;
	GHAssertEquals([subNodes count], (NSUInteger) 12, @"Should be one sub view");
	GHAssertEquals([subNodes objectAtIndex:0], self.testViewController.button1, @"Returned node was not button 1.");
	GHAssertEquals([subNodes objectAtIndex:1], self.testViewController.button2, @"Returned node was not button 2.");
	GHAssertEquals([subNodes objectAtIndex:2], self.testViewController.tabBar, @"Returned node was not the tab bar.");
	GHAssertEquals([subNodes objectAtIndex:3], self.testViewController.slider, @"Returned node was not the slider.");
	GHAssertEquals([subNodes objectAtIndex:4], self.testViewController.tableView, @"Returned node was not the tableView.");
	GHAssertEquals([subNodes objectAtIndex:5], self.testViewController.tapableLabel, @"Returned node was not the tapable label.");
	GHAssertEquals([subNodes objectAtIndex:6], self.testViewController.displayLabel, @"Returned node was not the display label.");
	GHAssertEquals([subNodes objectAtIndex:7], self.testViewController.waitForItButton, @"Returned node was not the wait for it button.");
	// There are more but at this point we can be sure it's pretty correct.
}

#pragma mark - Special attributes

-(void) testAttributeProtocol {
	handler.view = [[[UITextField alloc] init] autorelease];
	GHAssertTrue([handler dnHasAttribute:@"protocol" withValue:@"UITextInput"], @"Protocol not being detected");
	GHAssertFalse([handler dnHasAttribute:@"protocol" withValue:@"xxx"], @"Protocol not being detected");
}

-(void) testAttributeIsKindOfClass {
	handler.view = [[[UITextField alloc] init] autorelease];
	GHAssertTrue([handler dnHasAttribute:@"isKindOfClass" withValue:@"UIResponder"], @"Protocol not being detected");
	GHAssertFalse([handler dnHasAttribute:@"isKindOfClass" withValue:@"xxx"], @"Protocol not being detected");
}


#pragma mark - KVC

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

#pragma mark - SIUIAction tests

-(void) testTextEntryLowercase {
	handler.view = self.testViewController.textField;
	[self executeBlockOnMainThread:^{
		self.testViewController.textField.text = @"";
	}];
	[handler tap];
	NSString *text = @"abcdefghijklmnopqrstuvwxyz";
	[handler enterText:text keyRate:0.1 autoCorrect:NO];
	__block NSString *enteredText = nil;
	[self executeBlockOnMainThread:^{
		enteredText = [self.testViewController.textField.text retain];
	}];
	[enteredText autorelease];
	GHAssertEqualStrings(enteredText, text, @"Text not correct");
}

-(void) testTextEntryUppercase {
	handler.view = self.testViewController.textField;
	[self executeBlockOnMainThread:^{
		self.testViewController.textField.text = @"";
	}];
	[handler tap];
	NSString *text = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	[handler enterText:text keyRate:0.1 autoCorrect:NO];
	__block NSString *enteredText = nil;
	[self executeBlockOnMainThread:^{
		enteredText = [self.testViewController.textField.text retain];
	}];
	[enteredText autorelease];
	GHAssertEqualStrings(enteredText, text, @"Text not correct");
}

-(void) testTextEntryUnShiftedCharacters {
	handler.view = self.testViewController.textField;
	[self executeBlockOnMainThread:^{
		self.testViewController.textField.text = @"";
	}];
	[handler tap];
	NSString *text = @"1234567890-/:;()$&@\".,?!'";
	[handler enterText:text keyRate:0.1 autoCorrect:NO];
	__block NSString *enteredText = nil;
	[self executeBlockOnMainThread:^{
		enteredText = [self.testViewController.textField.text retain];
	}];
	[enteredText autorelease];
	GHAssertEqualStrings(enteredText, text, @"Text not correct");
}

-(void) testTextEntryShiftedCharacters {
	handler.view = self.testViewController.textField;
	[self executeBlockOnMainThread:^{
		self.testViewController.textField.text = @"";
	}];
	[handler tap];
	NSString *text = @"[]{}#%^*+=_\\|~<>\u20AC\u00A3\u00A5\u2022"; // Note that the bullet works even on the ipad keyboard which does not have the symbol.
	[handler enterText:text keyRate:0.1 autoCorrect:NO];
	__block NSString *enteredText = nil;
	[self executeBlockOnMainThread:^{
		enteredText = [self.testViewController.textField.text retain];
	}];
	[enteredText autorelease];
	GHAssertEqualStrings(enteredText, text, @"Text not correct");
}

-(void) testTextEntryAllowsAutoCorrect {
	handler.view = self.testViewController.textField;
	[self executeBlockOnMainThread:^{
		self.testViewController.textField.text = @"";
	}];
	[handler tap];
	NSString *text = @"cirrect tixt "; // Note that the bullet works even on the ipad keyboard which does not have the symbol.
	[handler enterText:text keyRate:0.1 autoCorrect:YES];
	__block NSString *enteredText = nil;
	[self executeBlockOnMainThread:^{
		enteredText = [self.testViewController.textField.text retain];
	}];
	[enteredText autorelease];
	GHAssertEqualStrings(enteredText, @"correct text ", @"Text not correct");
}


@end
