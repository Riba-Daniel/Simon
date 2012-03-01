//
//  SIMacroTests.m
//  Simon
//
//  Crea ted by Derek Clarkson on 20/01/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "SIMacros.h"
#import "AbstractTestWithControlsOnView.h"
#import "SIUITooManyFoundException.h"
#import "SIUINotFoundException.h"

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

SIMapStepToSelector(@"abc", dummyMethod)
-(void) testSIMapStepToSelector {
	
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
	GHFail(@"Mapping has not worked");	
}

#pragma mark - Fails tests

-(void) testSIFail {
   @try {
      SIFail();
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testSIFail](%i) SIFail executed, throwing failure exception.");
   }
}

-(void) testSIFailWithMessage {
   @try {
      SIFailM(@"abc %@", @"def");
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testSIFailWithMessage](%i) abc def");
   }
}

#pragma mark - Assert tests

-(void) testSIAssertNil {
   SIAssertNil(nil);
}

-(void) testSIAssertNilThrows {
   @try {
      SIAssertNil(@"abc");
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testSIAssertNilThrows](%i) SIAssertNil(@\"abc\") Expecting '@\"abc\"' to be nil.");
   }
}

-(void) testSIAssertNilThrowsWithMessage {
   @try {
      SIAssertNilM(@"abc", @"def %@", @"ghi");
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testSIAssertNilThrowsWithMessage](%i) def ghi");
   }
}

-(void) testSIAssertNotNil {
   SIAssertNotNil(@"abc");
}

-(void) testSIAssertNotNilThrows {
   @try {
      SIAssertNotNil(nil);
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testSIAssertNotNilThrows](%i) SIAssertNotNil(nil) 'nil' should be a valid object.");
   }
}

-(void) testSIAssertTrue {
   SIAssertTrue(YES);
}

-(void) testSIAssertTrueWithExpression {
   SIAssertTrue(45 == 45);
}

-(void) testSIAssertTrueWithObjectExpression {
   SIAssertTrue([[@"ABC" lowercaseString] isEqualToString:@"abc"]);
}

-(void) testSIAssertTrueThrows {
   @try {
      SIAssertTrue(NO);
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testSIAssertTrueThrows](%i) SIAssertTrue(NO) Expecting 'NO' to be YES, but it was NO.");
   }
}

-(void) testSIAssertFalse {
   SIAssertFalse(NO);
}

-(void) testSIAssertFalseWithExpression {
   SIAssertFalse(12 == 45);
}

-(void) testSIAssertFalseWithObjectExpression {
   SIAssertFalse([@"ABC" isEqualToString:@"abc"]);
}

-(void) testSIAssertFalseThrows {
   @try {
      SIAssertFalse(YES);
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testSIAssertFalseThrows](%i) SIAssertFalse(YES) Expecting 'YES' to be NO, but it was YES.");
   }
}

-(void) testSIAssertFalseThrowsWhenExpression {
   @try {
      SIAssertFalse(1 == 1);
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testSIAssertFalseThrowsWhenExpression](%i) SIAssertFalse(1 == 1) Expecting '1 == 1' to be NO, but it was YES.");
   }
}

#pragma mark - Equals tests

-(void) testSIAssertEqualsWithInts {
   SIAssertEquals(5, 5);
}

-(void) testSIAssertEqualsWithIntsThrows {
   @try {
      SIAssertEquals(1, 2);
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testSIAssertEqualsWithIntsThrows](%i) SIAssertEquals(1, 2) failed: 1 != 2");
   }
}

-(void) testSIAssertEqualsWithMixedTypes {
   SIAssertEquals(5, 5.0);
}

-(void) testSIAssertEqualsWithEquations {
   SIAssertEquals(45 / 45 * 5, 100 / 20.0);
}

-(void) testSIAssertEqualsWithObjectsProducingPrimitives {
   SIAssertEquals([[NSNumber numberWithDouble:12.0] floatValue], [[NSNumber numberWithInt:12] intValue]);
}

-(void) testSIAssertEqualsWithMixedTypesThrows {
   @try {
      SIAssertEquals(1.5, 2);
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testSIAssertEqualsWithMixedTypesThrows](%i) SIAssertEquals(1.5, 2) failed: 1.5 != 2");
   }
}

-(void) testSIAssertEqualsWithNulls {
   SIAssertEquals(NULL, NULL);
}

-(void) testSIAssertEqualsWithComplexExpressions {
   SIAssertEquals(NO ? 0 : 12, YES ? 12 : 0);
}

#pragma mark - Object comparison

-(void) testSIAssertObjectEqualsWithNils {
   SIAssertObjectEquals(nil, nil);
}

-(void) testSIAssertObjectEqualsWithNilAndStringThrows {
   @try {
      SIAssertObjectEquals(nil, @"abc");
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testSIAssertObjectEqualsWithNilAndStringThrows](%i) SIAssertObjectEquals(nil, @\"abc\") failed: nil != abc");
   }
}

-(void) testSIAssertObjectEqualsWithObjects {
   SIAssertObjectEquals(@"abc", @"abc");
}

-(void) testSIAssertObjectEqualsWithBuiltObjects {
   NSString *s1 = [NSString stringWithFormat:@"abc %@", @"def"];
   NSString *s2 = [NSString stringWithFormat:@"%@ def", @"abc"];
   SIAssertObjectEquals(s1, s2);
}

-(void) testSIAssertObjectEqualsWithDifferentTypes {
   SIAssertObjectEquals(@"12", [[NSNumber numberWithInt:12] stringValue]);
}

-(void) testSIAssertObjectEqualsWithObjectExpressions {
   NSString *s1 = [NSString stringWithFormat:@"abc %@", @"def"];
   NSString *s2 = [NSString stringWithFormat:@"%@ def", @"abc"];
   SIAssertObjectEquals([s1 substringFromIndex:2], [s2 substringFromIndex:2]);
}

-(void) testSIAssertObjectEqualsWithObjectsThrows {
   @try {
      SIAssertObjectEquals(@"def", @"abc");
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testSIAssertObjectEqualsWithObjectsThrows](%i) SIAssertObjectEquals(@\"def\", @\"abc\") failed: def != abc");
   }
}

#pragma mark - UI Tests - Finding

-(void) testSIFindViewReturnsErrors {
   @try {
      SIFindView(@"/xxx");
      GHFail(@"Exception not thrown");
   }
   @catch (SIUINotFoundException *exception) {
      GHAssertEqualStrings(exception.name, NSStringFromClass([SIUINotFoundException class]), @"Incorrect domain");
      GHAssertEqualStrings(exception.reason, @"Path /xxx failed to find anything.", @"Reason incorrect");
   }
}

-(void) testSIFindViewFindsASingleControl {
	UIView *foundView = SIFindView(@"//UIRoundedRectButton[@titleLabel.text='Button 1']");
	GHAssertNotNil(foundView, @"Nil returned");
	GHAssertEqualObjects(foundView, self.testViewController.button1, @"Returned view is not a match");
}

-(void) testSIFindViewsFindsASingleControl {
	NSArray *foundViews = SIFindViews(@"//UIRoundedRectButton[@titleLabel.text='Button 1']");
	GHAssertNotNil(foundViews, @"Nil returned");
	GHAssertEqualObjects([foundViews objectAtIndex:0], self.testViewController.button1, @"Returned view is not a match");
}

#pragma mark - UI Tests - Tapping

-(void) testSITapControl {
   self.testViewController.tappedButton = 0;
	SITapControl(@"//UIRoundedRectButton[@titleLabel.text='Button 1']");
	GHAssertEquals(self.testViewController.tappedButton, 1, @"Tapped flag not set. Control tapping may not have worked");
}

-(void) testSITapButtonWithLabel {
   self.testViewController.tappedButton = 0;
	SITapButtonWithLabel(@"Button 1");
	GHAssertEquals(self.testViewController.tappedButton, 1, @"Tapped flag not set. Control tapping may not have worked");
}

-(void) testSITapButtonWithLabelFailsIfButtonNotFound {
   @try {
      SITapButtonWithLabel(@"Button 3");
      GHFail(@"Exception not thrown");
   }
   @catch (SIUINotFoundException *exception) {
      GHAssertEqualStrings(exception.name, NSStringFromClass([SIUINotFoundException class]), @"Incorrect domain");
      GHAssertEqualStrings(exception.reason, @"Button 3 not found.", @"Reason incorrect");
   }
}

-(void) testTapButtonWithLabelAndWait {

   self.testViewController.tappedButton = 0;
   NSDate *before = [NSDate date];
   SITapButtonWithLabelAndWait(@"Button 1",1.0);
   NSTimeInterval diff = [before timeIntervalSinceNow];
   
   GHAssertEquals(self.testViewController.tappedButton, 1, @"Button not tapped");
   GHAssertLessThan(diff, -1.0, @"Not enough time passed");
}

-(void) testTapTabBarItems {
   self.testViewController.tappedTabBarItem = 0;
   SITapTabBarButtonWithLabel(@"More");
	GHAssertEquals(self.testViewController.tappedTabBarItem, 2, @"Tapped flag not set. Control tapping may not have worked");
   SITapTabBarButtonWithLabel(@"Favorites");
	GHAssertEquals(self.testViewController.tappedTabBarItem, 1, @"Tapped flag not set. Control tapping may not have worked");
}

#pragma mark - UI Tests - Swiping
-(void) testSwipeSliderRight {
   self.testViewController.slider.value = 5;
   SISwipeControlInDirectionDistance(@"//UISlider", SIUISwipeDirectionRight, 50);
	GHAssertEquals(round(self.testViewController.slider.value), 7.0, @"Slider not slide.");
}

-(void) testSwipeSliderLeft {
   self.testViewController.slider.value = 5;
   SISwipeControlInDirectionDistance(@"//UISlider", SIUISwipeDirectionLeft, 50);
	GHAssertEquals(round(self.testViewController.slider.value), 3.0, @"Slider not slide.");
}

-(void) testSwipeThrowsWhenNotFound {
   @try {
      SISwipeControlInDirectionDistance(@"//XXX", SIUISwipeDirectionRight, 50);
      GHFail(@"Exception not thrown");
   }
   @catch (SIUINotFoundException *exception) {
      GHAssertEqualStrings(exception.name, NSStringFromClass([SIUINotFoundException class]), @"Incorrect domain");
      GHAssertEqualStrings(exception.reason, @"Path //XXX failed to find anything.", @"Reason incorrect");
   }
}

#pragma mark - Others

-(void) testPauseFor {
   NSDate *before = [NSDate date];
   SIPauseFor(0.5);
   NSTimeInterval diff = [before timeIntervalSinceNow];
   GHAssertLessThan(diff, -0.5, @"Not enough time passed");
}

#pragma mark - Helpers

-(void) dummyMethod {}

-(void) verifyException:(NSException *) exception description:(NSString *) expectedDescription {
   GHAssertEqualStrings(exception.name, @"SIAssertionException", @"Incorrect exception: %@", exception);
   GHAssertEqualStrings(exception.description, expectedDescription, @"Incorrect exception");
}


@end
