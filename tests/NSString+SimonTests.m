//
//  NSObject+UtilsTests.m
//  Simon
//
//  Created by Derek Clarkson on 6/15/11.
//  Copyright 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>
#import "SIConstants.h"
#import "NSString+Simon.h"

@interface NSString_SimonTests : GHTestCase {}

@end

@implementation NSString_SimonTests

-(void) testStringToKeywordGivenWrongCase {
	GHAssertEquals([@"GiVeN" keywordFromString] , SIKeywordGiven, @"Unexpected keyword returned");
}

-(void) testStringToKeywordGiven {
	GHAssertEquals([@"Given" keywordFromString] , SIKeywordGiven, @"Unexpected keyword returned");
}

-(void) testStringToKeywordThen {
	GHAssertEquals([@"Then" keywordFromString] , SIKeywordThen, @"Unexpected keyword returned");
}

-(void) testStringToKeywordAs {
	GHAssertEquals([@"As" keywordFromString] , SIKeywordAs, @"Unexpected keyword returned");
}

-(void) testStringToKeywordAnd {
	GHAssertEquals([@"And" keywordFromString] , SIKeywordAnd, @"Unexpected keyword returned");
}

-(void) testStringToKeywordNonKeyword {
	GHAssertEquals([@"abc" keywordFromString] , SIKeywordUnknown, @"Unexpected keyword returned");
}

-(void) testKeywordToStringGiven {
	GHAssertEqualStrings([NSString stringFromKeyword:SIKeywordGiven], @"Given", @"Incorrect String returned");
}

-(void) testKeywordToStringThen {
	GHAssertEqualStrings([NSString stringFromKeyword:SIKeywordThen], @"Then", @"Incorrect String returned");
}

-(void) testKeywordToStringAs {
	GHAssertEqualStrings([NSString stringFromKeyword:SIKeywordAs], @"As", @"Incorrect String returned");
}

-(void) testKeywordToStringAnd {
	GHAssertEqualStrings([NSString stringFromKeyword:SIKeywordAnd], @"And", @"Incorrect String returned");
}

-(void) testKeywordToStringUnknown {
	GHAssertEqualStrings([NSString stringFromKeyword:SIKeywordUnknown], @"Unknown", @"Incorrect String returned");
}

-(void) testStripsSingleQuotes {
	GHAssertEqualStrings([@"'abc'" stringByRemovingQuotes], @"abc", @"Quotes not removed");
}

-(void) testStripsDoubleQuotes {
	GHAssertEqualStrings([@"\"abc\"" stringByRemovingQuotes], @"abc", @"Quotes not removed");
}

-(void) testLeavesNonQuotedStringAlone {
	GHAssertEqualStrings([@"abc" stringByRemovingQuotes], @"abc", @"Quotes not removed");
}

-(void) testStripsDoubleQuotesButLeavesEmbeddedQuotes {
	GHAssertEqualStrings([@"\"a\"b\"c\"" stringByRemovingQuotes], @"a\"b\"c", @"Quotes not removed");
}

-(void) testHasPrefixWithOptionsNoMatch {
	GHAssertFalse([@"abcdef" hasPrefix:@"xyz" options:0], @"Should not have matched");
}

-(void) testHasPrefixWithOptionsTooShortToMatch {
	GHAssertFalse([@"abc" hasPrefix:@"abcdef" options:0], @"Should not have matched");
}

-(void) testHasPrefixWithOptionsExactMatch {
	GHAssertTrue([@"abc" hasPrefix:@"abc" options:0], @"Should have matched");
}

-(void) testHasPrefixWithOptionsPrefixMatch {
	GHAssertTrue([@"abcdef" hasPrefix:@"abc" options:0], @"Should have matched");
}

-(void) testHasPrefixWithOptionsCaseInsensitiveMatch {
	GHAssertTrue([@"aBCdef" hasPrefix:@"abc" options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch], @"Should have matched");
}

-(void) testHasPrefixWithOptionsDiacraticInsensitiveMatch {
	GHAssertTrue([@"defg" hasPrefix:@"dË" options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch], @"Should have matched");
}


@end
