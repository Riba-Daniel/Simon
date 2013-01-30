//
//  SIMacroTests.m
//  Simon
//
//  Crea ted by Derek Clarkson on 20/01/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Simon/Simon.h>

#import <GHUnitIOS/GHUnit.h>
#import "AbstractTestWithControlsOnView.h"
#import <Simon/SIUITooManyFoundException.h>
#import <Simon/SIUINotFoundException.h>
#import <Simon/NSObject+Simon.h>
#import <Simon/SIRuntime.h>

#define catchMessage(msg) \
do { \
NSString *newMsg = [NSString stringWithFormat:msg, (__LINE__ - 4)]; \
[self verifyException:exception description:newMsg]; \
} while (NO)

@interface SIMacroTests : AbstractTestWithControlsOnView
-(void) dummyMethod;
-(void) verifyException:(NSException *) exception description:(NSString *) expectedDescription;
@end

@implementation SIMacroTests

#pragma mark - Mappings

mapStepToSelector(@"abc", dummyMethod);
-(void) testMapStepToSelector {
	
	// First find the mapping.
	SIRuntime *runtime = [[[SIRuntime alloc] init] autorelease];
	NSArray *methods = [runtime allMappingMethodsInRuntime];
	
	for (SIStepMapping *mapping in methods) {
		if (mapping.targetClass == [self class]
			 && mapping.selector == @selector(dummyMethod)) {
			// good so exit.
			return;
		}
	}
	GHFail(@"Mapping not found in runtime");
}

#pragma mark - Fails tests

-(void) testFail {
   @try {
      fail(@"abc");
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testFail](%i) abc");
   }
}

#pragma mark - Assert tests

-(void) testAssertNil {
   assertNil(nil);
}

-(void) testAssertNilThrows {
   @try {
      assertNil(@"abc");
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testAssertNilThrows](%i) assertNil(@\"abc\") Expecting '@\"abc\"' to be nil.");
   }
}

-(void) testAssertNotNil {
   assertNotNil(@"abc");
}

-(void) testAssertNotNilThrows {
   @try {
      assertNotNil(nil);
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testAssertNotNilThrows](%i) assertNotNil(nil) 'nil' should be a valid object.");
   }
}

-(void) testAssertTrue {
   assertTrue(YES);
}

-(void) testAssertTrueWithExpression {
   assertTrue(45 == 45);
}

-(void) testAssertTrueWithObjectExpression {
   assertTrue([[@"ABC" lowercaseString] isEqualToString:@"abc"]);
}

-(void) testAssertTrueThrows {
   @try {
      assertTrue(NO);
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testAssertTrueThrows](%i) assertTrue(NO) Expecting 'NO' to be YES, but it was NO.");
   }
}

-(void) testAssertFalse {
   assertFalse(NO);
}

-(void) testAssertFalseWithExpression {
   assertFalse(12 == 45);
}

-(void) testAssertFalseWithObjectExpression {
   assertFalse([@"ABC" isEqualToString:@"abc"]);
}

-(void) testAssertFalseThrows {
   @try {
      assertFalse(YES);
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testAssertFalseThrows](%i) assertFalse(YES) Expecting 'YES' to be NO, but it was YES.");
   }
}

-(void) testAssertFalseThrowsWhenExpression {
   @try {
      assertFalse(1 == 1);
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testAssertFalseThrowsWhenExpression](%i) assertFalse(1 == 1) Expecting '1 == 1' to be NO, but it was YES.");
   }
}

-(void) testAssertViewPresent {
   assertViewPresent(@"//UIRoundedRectButton[titleLabel.text='Button 1']");
}

-(void) testAssertViewPresentThrows {
   @try {
		assertViewPresent(@"//xxx");
      GHFail(@"Exception not thrown");
	}
	@catch (NSException *exception) {
		catchMessage(@"-[SIMacroTests testAssertViewPresentThrows](%i) assertViewPresent(@\"//xxx\") Expected '//xxx' to find a UIView.");
	}
}

-(void) testAssertViewNotPresent {
   assertViewNotPresent(@"//xxx");
}

-(void) testAssertViewNotPresentThrows {
   @try {
		assertViewNotPresent(@"//UIRoundedRectButton[titleLabel.text='Button 1']");
      GHFail(@"Exception not thrown");
	}
	@catch (NSException *exception) {
		catchMessage(@"-[SIMacroTests testAssertViewNotPresentThrows](%i) assertViewNotPresent(@\"//UIRoundedRectButton[titleLabel.text='Button 1']\") Expected '//UIRoundedRectButton[titleLabel.text='Button 1']' to not find a UIView.");
	}
}

-(void) testAssertLabelTextEquals {
   assertLabelTextEquals(self.testViewController.tapableLabel, @"Tapable Label");
}

-(void) testAssertLabelTextEqualsThrows {
   @try {
		assertLabelTextEquals(self.testViewController.tapableLabel, @"XXX");
      GHFail(@"Exception not thrown");
	}
	@catch (NSException *exception) {
		catchMessage(@"-[SIMacroTests testAssertLabelTextEqualsThrows](%i) assertLabelTextEquals(self.testViewController.tapableLabel, @\"XXX\") failed. Found label text: 'Tapable Label' instead.");
	}
}

#pragma mark - Equals tests

-(void) testAssertEqualsWithInts {
   assertEquals(5, 5);
}

-(void) testAssertEqualsWithIntsThrows {
   @try {
      assertEquals(1, 2);
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testAssertEqualsWithIntsThrows](%i) assertEquals(1, 2) failed: 1 != 2");
   }
}

-(void) testAssertEqualsWithMixedTypes {
   assertEquals(5, 5.0);
}

-(void) testAssertEqualsWithEquations {
   assertEquals(45 / 45 * 5, 100 / 20.0);
}

-(void) testAssertEqualsWithObjectsProducingPrimitives {
   assertEquals([[NSNumber numberWithDouble:12.0] floatValue], [[NSNumber numberWithInt:12] intValue]);
}

-(void) testAssertEqualsWithMixedTypesThrows {
   @try {
      assertEquals(1.5, 2);
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testAssertEqualsWithMixedTypesThrows](%i) assertEquals(1.5, 2) failed: 1.5 != 2");
   }
}

-(void) testAssertEqualsWithNulls {
   assertEquals(NULL, NULL);
}

-(void) testAssertEqualsWithComplexExpressions {
   assertEquals(NO ? 0 : 12, YES ? 12 : 0);
}

#pragma mark - Object comparison

-(void) testAssertObjectEqualsWithNils {
   assertObjectEquals(nil, nil);
}

-(void) testAssertObjectEqualsWithNilAndStringThrows {
   @try {
      assertObjectEquals(nil, @"abc");
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testAssertObjectEqualsWithNilAndStringThrows](%i) assertObjectEquals(nil, @\"abc\") failed.");
   }
}

-(void) testAssertObjectEqualsWithObjects {
   assertObjectEquals(@"abc", @"abc");
}

-(void) testAssertObjectEqualsWithBuiltObjects {
   NSString *s1 = [NSString stringWithFormat:@"abc %@", @"def"];
   NSString *s2 = [NSString stringWithFormat:@"%@ def", @"abc"];
   assertObjectEquals(s1, s2);
}

-(void) testAssertObjectEqualsWithDifferentTypes {
   assertObjectEquals(@"12", [[NSNumber numberWithInt:12] stringValue]);
}

-(void) testAssertObjectEqualsWithObjectExpressions {
   NSString *s1 = [NSString stringWithFormat:@"abc %@", @"def"];
   NSString *s2 = [NSString stringWithFormat:@"%@ def", @"abc"];
   assertObjectEquals([s1 substringFromIndex:2], [s2 substringFromIndex:2]);
}

-(void) testAssertObjectEqualsWithObjectsThrows {
   @try {
      assertObjectEquals(@"def", @"abc");
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testAssertObjectEqualsWithObjectsThrows](%i) assertObjectEquals(@\"def\", @\"abc\") failed.");
   }
}

#pragma mark - UI Tests - Finding

-(void) testViewWithQueryReturnsErrors {
   @try {
      viewWithQuery(@"/xxx");
      GHFail(@"Exception not thrown");
   }
   @catch (SIUINotFoundException *exception) {
      GHAssertEqualStrings(exception.name, NSStringFromClass([SIUINotFoundException class]), @"Incorrect domain");
      GHAssertEqualStrings(exception.reason, @"Path /xxx failed to find anything.", @"Reason incorrect");
   }
}

-(void) testViewWithQueryFindsButton {
	UIView *foundView = viewWithQuery(@"//UIRoundedRectButton[titleLabel.text='Button 1']");
	GHAssertNotNil(foundView, @"Nil returned");
	GHAssertEqualObjects(foundView, self.testViewController.button1, @"Returned view is not a match");
}

-(void) testButtonWithLabelFindsButton {
	UIView *foundButton = buttonWithLabel(@"Button 1");
	GHAssertNotNil(foundButton, @"Nil returned");
	GHAssertEqualObjects(foundButton, self.testViewController.button1, @"Returned view is not a match");
}

-(void) testIsPresentReturnsYes {
	GHAssertTrue(isPresent(@"//UIRoundedRectButton/UIButtonLabel[text='Button 1']/.."), @"Should have returned YES");
}

-(void) testIsPresentReturnsNo {
	GHAssertFalse(isPresent(@"xxxx"), @"Should have returned NO");
}

#pragma mark - UI Tests - Tapping

-(void) testTapWithView {
   self.testViewController.tappedButton = 0;
	tap(self.testViewController.button1);
	GHAssertEquals(self.testViewController.tappedButton, 1, @"Tapped flag not set. Control tapping may not have worked");
}

#pragma mark - UI Tests - Swiping

-(void) testSwipeSliderRight {
   self.testViewController.slider.value = 5;
   swipe(self.testViewController.slider, SIUISwipeDirectionRight, 50);
	GHAssertEquals(round(self.testViewController.slider.value), 7.0, @"Slider not slide.");
}

-(void) testSwipeSliderLeft {
   self.testViewController.slider.value = 5;
   swipe(self.testViewController.slider, SIUISwipeDirectionLeft, 50);
	GHAssertEquals(round(self.testViewController.slider.value), 3.0, @"Slider not slide.");
}

#pragma mark - Pauses and Waits

-(void) testPauseFor {
   NSDate *before = [NSDate date];
   pauseFor(0.5);
   NSTimeInterval diff = [before timeIntervalSinceNow];
   GHAssertLessThan(diff, -0.5, @"Not enough time passed");
}

-(void) testWaitForViewWithQuery {
   self.testViewController.displayLabel.text = @"...";
   [[SIUIApplication application] tap:self.testViewController.waitForItButton];
   GHAssertEqualStrings(self.testViewController.displayLabel.text, @"...", @"Label should not be updated yet");
   UIView *label = waitForView(@"//UILabel[text='Clicked!']", 0.5, 5);
   GHAssertNotNil(label, @"Nothing returned");
   GHAssertEqualStrings(self.testViewController.displayLabel.text, @"Clicked!", @"Button should have updated by now");
}

#pragma mark - Animation

-(void) testWaitForAnimationFinish {
	
	dispatch_queue_t mainQueue = dispatch_get_main_queue();
   NSDate *before = [NSDate date];
	dispatch_async(mainQueue, ^{
		CGPoint originalCenter = self.testViewController.waitForItButton.center;
		[UIView animateWithDuration:1.0
									 delay:0.0
								  options:UIViewAnimationOptionAutoreverse
							  animations: ^{
								  self.testViewController.waitForItButton.center = CGPointMake(originalCenter.x + 100, originalCenter.y);
							  }
							  completion:^(BOOL finished) {
								  self.testViewController.waitForItButton.center = originalCenter;
							  }];
	});
	
	waitForViewAnimationsToFinish(@"//UIRoundedRectButton[titleLabel.text='Wait for it!']", 0.1);
	
   NSTimeInterval diff = fabs([before timeIntervalSinceNow]);
	GHAssertGreaterThan(diff, 2.0, @"not long enough, animation not finished.");
	
}

#pragma mark - Text entry

-(void) testEnterTextIntoView {
	[self executeBlockOnMainThread:^{
		self.testViewController.textField.text = @"";
	}];
	
	NSString *text = @"ABC DEF GHI klm nop qrs tuv-w.y,y:z";
	[SIUIApplication application].disableKeyboardAutocorrect = YES;
	
	enterText(self.testViewController.textField, text);
	
	__block NSString *enteredText = nil;
	[self executeBlockOnMainThread:^{
		enteredText = [self.testViewController.textField.text retain];
	}];
	[enteredText autorelease];
	GHAssertEqualStrings(enteredText, text, @"Text not correct");
}

#pragma mark - Helpers

-(void) dummyMethod {}

-(void) verifyException:(NSException *) exception description:(NSString *) expectedDescription {
   GHAssertEqualStrings(exception.name, ASSERTION_EXCEPTION_NAME, @"Incorrect exception: %@", exception);
   GHAssertEqualStrings(exception.description, expectedDescription, @"Incorrect exception");
}


@end
