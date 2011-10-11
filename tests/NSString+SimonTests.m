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

@interface NSObject_UtilsTests : GHTestCase {}

@end

@implementation NSObject_UtilsTests

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


@end
