

#import <GHUnitIOS/GHUnit.h>
#import <Simon/SIUIViewHandler.h>
#import <dUsefulStuff/DCCommon.h>
#import "AbstractTestWithControlsOnView.h"
#import <Simon/NSObject+Simon.h>

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
	handler.view = (UIView<DNNode> *) self.testViewController.button1;
	GHAssertEqualStrings(handler.dnName, @"UIRoundedRectButton", @"Incorrect node returned");
}

-(void) testParentName {
	handler.view = (UIView<DNNode> *) self.testViewController.button1;
	GHAssertEquals(handler.dnParentNode, self.testViewController.view, @"Incorrect name returned");
}

-(void) testAttributeQueryIgnoresInvalidPropertyName {
	handler.view = (UIView<DNNode> *) self.testViewController.button1;
	GHAssertFalse([handler dnHasAttribute:@"xyz" withValue:nil], nil);
}

-(void) testAttributeQueryMatchesPropertyValue {
	handler.view = (UIView<DNNode> *) self.testViewController.button1;
	GHAssertTrue([handler dnHasAttribute:@"alpha" withValue:@"1"], @"Handler fails to match attribute data");
}

-(void) testAttributeQueryMatchesPropertyValueWhenNumericWithNumber {
	handler.view = (UIView<DNNode> *) self.testViewController.button3;
	GHAssertTrue([handler dnHasAttribute:@"alpha" withValue:@"1.0"], nil);
}

-(void) testAttributeQueryMatchesNestedPropertyValue {
	handler.view = (UIView<DNNode> *) self.testViewController.button1;
	GHAssertTrue([handler dnHasAttribute:@"titleLabel.text" withValue:@"Button 1"], @"Handler fails to match attribute data");
}

-(void) testAttributeQueryIgnoresUnknownPropertyValue {
	handler.view = (UIView<DNNode> *) self.testViewController.tabBar;
	GHAssertFalse([handler dnHasAttribute:@"titleLabel.text" withValue:nil], nil);
}

-(void) testSubnodes {
   handler.view = (UIView<DNNode> *) self.testViewController.view;
	NSArray *subNodes = handler.dnSubNodes;
	GHAssertEquals([subNodes count], (NSUInteger) 13, @"Should be one sub view");
}

#pragma mark - Special attributes

-(void) testAttributeProtocol {
	handler.view = (UIView<DNNode> *) [[[UITextField alloc] init] autorelease];
	GHAssertTrue([handler dnHasAttribute:@"protocol" withValue:@"UITextInput"], @"Protocol not being detected");
	GHAssertFalse([handler dnHasAttribute:@"protocol" withValue:@"xxx"], @"Protocol not being detected");
}

-(void) testAttributeIsKindOfClass {
	handler.view = (UIView<DNNode> *) [[[UITextField alloc] init] autorelease];
	GHAssertTrue([handler dnHasAttribute:@"isKindOfClass" withValue:@"UIResponder"], @"Protocol not being detected");
	GHAssertFalse([handler dnHasAttribute:@"isKindOfClass" withValue:@"xxx"], @"Protocol not being detected");
}


#pragma mark - KVC

-(void) testKvcAttributesReturnsNilWhenNoTag {
   handler.view = (UIView<DNNode> *) [[[UIView alloc] init] autorelease];
	GHAssertNil([handler kvcAttributes], @"Expected a nil");
}

-(void) testKvcAttributesReturnsAttributesWhenTagSet {
   handler.view = (UIView<DNNode> *) [[[UIView alloc] init] autorelease];
	handler.view.tag = 1;
	NSDictionary *attributes = [handler kvcAttributes];
	GHAssertNotNil(attributes, @"Expected aattributes");
	GHAssertEquals([attributes objectForKey:@"tag"], [NSNumber numberWithInt:1], @"Attribute not returned");
}

-(void) testKvcAttributesReturnsAttributesWhenAccessibilityIndentifierSet {
   handler.view = (UIView<DNNode> *) [[[UIView alloc] init] autorelease];
	handler.view.accessibilityIdentifier = @"abc";
	NSDictionary *attributes = [handler kvcAttributes];
	GHAssertNotNil(attributes, @"Expected aattributes");
	GHAssertEquals([attributes objectForKey:@"accessibilityIdentifier"], @"abc", @"Attribute not returned");
}

-(void) testKvcAttributesReturnsAttributesWhenAccessibilityLabelSet {
   handler.view = (UIView<DNNode> *) [[[UIView alloc] init] autorelease];
	handler.view.accessibilityLabel = @"abc";
	NSDictionary *attributes = [handler kvcAttributes];
	GHAssertNotNil(attributes, @"Expected aattributes");
	GHAssertEquals([attributes objectForKey:@"accessibilityLabel"], @"abc", @"Attribute not returned");
}

-(void) testKvcAttributesReturnsAttributesWhenAccessibilityValueSet {
   handler.view = (UIView<DNNode> *) [[[UIView alloc] init] autorelease];
	handler.view.accessibilityValue = @"abc";
	NSDictionary *attributes = [handler kvcAttributes];
	GHAssertNotNil(attributes, @"Expected attributes");
	GHAssertEquals([attributes objectForKey:@"accessibilityValue"], @"abc", @"Attribute not returned");
}

#pragma mark - SIUIAction tests

-(void) testTextEntryLowercase {
	handler.view = (UIView<DNNode> *) self.testViewController.textField;
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
	handler.view = (UIView<DNNode> *) self.testViewController.textField;
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
	handler.view = (UIView<DNNode> *) self.testViewController.textField;
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
	handler.view = (UIView<DNNode> *) self.testViewController.textField;
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
	handler.view = (UIView<DNNode> *) self.testViewController.textField;
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
