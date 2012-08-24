//
//  NSObject+UtilsTests.m
//  Simon
//
//  Created by Derek Clarkson on 6/15/11.
//  Copyright 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIConstants.h>
#import <Simon/NSString+Simon.h>

@interface NSString_SimonTests : GHTestCase {}

@end

@implementation NSString_SimonTests

-(void) testSIKeywordGivenWrongCase {
	GHAssertEquals([@"GiVeN" siKeyword] , SIKeywordGiven, nil);
}

-(void) testSIKeywordGiven {
	GHAssertEquals([@"Given" siKeyword] , SIKeywordGiven, nil);
}

-(void) testSIToKeywordThen {
	GHAssertEquals([@"Then" siKeyword] , SIKeywordThen, nil);
}

-(void) testSIKeywordAs {
	GHAssertEquals([@"As" siKeyword] , SIKeywordAs, nil);
}

-(void) testSIKeywordAnd {
	GHAssertEquals([@"And" siKeyword] , SIKeywordAnd, nil);
}

-(void) testSIKeywordNonKeyword {
	GHAssertEquals([@"abc" siKeyword] , SIKeywordUnknown, nil);
}

-(void) testStringFromSIKeywordGiven {
	GHAssertEqualStrings([NSString stringFromSIKeyword:SIKeywordGiven], @"Given", nil);
}

-(void) testStringFromSIKeywordThen {
	GHAssertEqualStrings([NSString stringFromSIKeyword:SIKeywordThen], @"Then", nil);
}

-(void) testStringFromSIKeywordAs {
	GHAssertEqualStrings([NSString stringFromSIKeyword:SIKeywordAs], @"As", nil);
}

-(void) testStringFromSIKeywordAnd {
	GHAssertEqualStrings([NSString stringFromSIKeyword:SIKeywordAnd], @"And", nil);
}

-(void) testStringFromSIKeywordUnknown {
	GHAssertEqualStrings([NSString stringFromSIKeyword:SIKeywordUnknown], @"Unknown", nil);
}

-(void) testStringByRemovingQuotesStripsSingleQuotes {
	GHAssertEqualStrings([@"'abc'" stringByRemovingQuotes], @"abc", nil);
}

-(void) testStringByRemovingQuotesStripsDoubleQuotes {
	GHAssertEqualStrings([@"\"abc\"" stringByRemovingQuotes], @"abc", nil);
}

-(void) testStringByRemovingQuotesLeavesNonQuotedStringAlone {
	GHAssertEqualStrings([@"abc" stringByRemovingQuotes], @"abc", nil);
}

-(void) testStringByRemovingQuotesStripsDoubleQuotesButLeavesEmbeddedQuotes {
	GHAssertEqualStrings([@"\"a\"b\"c\"" stringByRemovingQuotes], @"a\"b\"c", nil);
}

-(void) testHasPrefixWithOptionsNoMatch {
	GHAssertFalse([@"abcdef" hasPrefix:@"xyz" options:0], nil);
}

-(void) testHasPrefixWithOptionsTooShortToMatch {
	GHAssertFalse([@"abc" hasPrefix:@"abcdef" options:0], nil);
}

-(void) testHasPrefixWithOptionsExactMatch {
	GHAssertTrue([@"abc" hasPrefix:@"abc" options:0], nil);
}

-(void) testHasPrefixWithOptionsPrefixMatch {
	GHAssertTrue([@"abcdef" hasPrefix:@"abc" options:0], nil);
}

-(void) testHasPrefixWithOptionsCaseInsensitiveMatch {
	GHAssertTrue([@"aBCdef" hasPrefix:@"abc" options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch], nil);
}

-(void) testHasPrefixWithOptionsDiacraticInsensitiveMatch {
	GHAssertTrue([@"defg" hasPrefix:@"dË" options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch], nil);
}

-(void) testIsEmptyWithNil {
	GHAssertTrue([NSString isEmpty:nil], nil);
}

-(void) testIsEmptyWithZeroLength {
	GHAssertTrue([NSString isEmpty:@""], nil);
}

-(void) testIsEmptyWithWhitespace {
	GHAssertTrue([NSString isEmpty:@"\n\t"], nil);
}

-(void) testIsEmptyWithSpaces {
	GHAssertTrue([NSString isEmpty:@"   "], nil);
}

-(void) testIsEmptyWithText {
	GHAssertFalse([NSString isEmpty:@"  Hello \n world"], nil);
}

-(void) testSIHttpMethodWithPost {
	GHAssertEquals([@"post" siHttpMethod], SIHttpMethodPost, nil);
}

-(void) testSIHttpMethodWithGet {
	GHAssertEquals([@"get" siHttpMethod], SIHttpMethodGet, nil);
}

-(void) testSIHttpMethodWithUnknown {
	GHAssertEquals([@"xxx" siHttpMethod], SIHttpMethodUnknown, nil);
}

@end
