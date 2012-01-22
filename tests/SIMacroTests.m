//
//  SIMacroTests.m
//  Simon
//
//  Created by Derek Clarkson on 20/01/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "SIMacros.h"

#define catchMessage(msg) \
do { \
    NSString *newMsg = [NSString stringWithFormat:msg, (__LINE__ - 4)]; \
   [self verifyException:exception description:newMsg]; \
} while (NO)

@interface SIMacroTests : GHTestCase
-(void) verifyException:(NSException *) exception description:(NSString *) expectedDescription;
@end

@implementation SIMacroTests

#pragma mark - fails tests
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
      catchMessage(@"-[SIMacroTests testSIAssertNilThrows](%i) Expecting '@\"abc\"' to be nil.");
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
      catchMessage(@"-[SIMacroTests testSIAssertNotNilThrows](%i) Expecting 'nil' to be a valid pointer to something.");
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
      catchMessage(@"-[SIMacroTests testSIAssertTrueThrows](%i) Expecting 'NO' to be YES, but it was NO.");
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
      catchMessage(@"-[SIMacroTests testSIAssertFalseThrows](%i) Expecting 'YES' to be NO, but it was YES.");
   }
}

-(void) testSIAssertFalseThrowsWhenExpression {
   @try {
      SIAssertFalse(1 == 1);
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testSIAssertFalseThrowsWhenExpression](%i) Expecting '1 == 1' to be NO, but it was YES.");
   }
}

#pragma mark- Equals tests

-(void) testSIAssertEqualsWithInts {
   SIAssertEquals(5, 5);
}

-(void) testSIAssertEqualsWithIntsThrows {
   @try {
      SIAssertEquals(1, 2);
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testEqualsWithIntsThrows](%i) SIAssertEquals failed: 1 != 2");
   }
}

-(void) testSIAssertEqualsWithMixedTypes {
   SIAssertEquals(5, 5.0);
}

-(void) testSIAssertEqualsWithMixedTypesThrows {
   @try {
      SIAssertEquals(1.5, 2);
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testEqualsWithMixedTypesThrows](%i) SIAssertEquals failed: 1.5 != 2");
   }
}

-(void) testSIAssertEqualsWithNulls {
   SIAssertEquals(NULL, NULL);
}

#pragma mark - Object comparison

-(void) testSIAssertEqualsWithNils {
   SIAssertObjectEquals(nil, nil);
}

-(void) testSIAssertEqualsWithNilAndStringThrows {
   @try {
      SIAssertObjectEquals(nil, @"abc");
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testEqualsWithNilAndStringThrows](%i) SIAssertEquals failed: nil != @\"abc\"");
   }
}

-(void) testSIAssertEqualsWithObjects {
   SIAssertObjectEquals(@"abc", @"abc");
}

-(void) testSIAssertEqualsWithObjectsThrows {
   @try {
      SIAssertObjectEquals(@"def", @"abc");
      GHFail(@"Exception not thrown");
   }
   @catch (NSException *exception) {
      catchMessage(@"-[SIMacroTests testEqualsWithObjectsThrows](%i) SIAssertEquals failed: @\"def\" != @\"abc\"");
   }
}

#pragma mark - Private methods.

-(void) verifyException:(NSException *) exception description:(NSString *) expectedDescription {
   GHAssertEqualStrings(exception.name, @"SIAssertionException", @"Incorrect exception: %@", exception);
   GHAssertEqualStrings(exception.description, expectedDescription, @"Incorrect exception");
}

@end
