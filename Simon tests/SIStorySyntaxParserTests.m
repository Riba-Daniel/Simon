//
//  SIStorySyntaxParserTests.m
//  Simon
//
//  Created by Derek Clarkson on 1/11/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>

#import <Simon/SIConstants.h>
#import <Simon/SIStorySyntaxParser.h>

@interface SIStorySyntaxParserTests : GHTestCase {
	@private
	SIStorySyntaxParser *parser;
	NSError *error;
}

-(void) checkLine:(NSString *) line failsWithMessage:(NSString *) msg;

@end

@implementation SIStorySyntaxParserTests

-(void) setUp {
	parser = [[SIStorySyntaxParser alloc] init];
	error = NULL;
}

-(void) tearDown {
	DC_DEALLOC(parser);
}

-(void) testUnknownKeyword {
	GHAssertEquals([parser checkLine:@"xyz abc" error:&error], SIKeywordUnknown, nil);
   GHAssertEquals(error.code, SIErrorInvalidKeyword, nil);
	GHAssertEqualStrings(error.userInfo[NSLocalizedFailureReasonErrorKey], @"Each line of a story must start with a valid keyword (As, Given, When, Then or And) or a comment. \"xyz\" is not a keyword.", nil);
}

-(void) testBigStory {
	GHAssertEquals([parser checkLine:@"story: abc" error:&error], SIKeywordStory, nil);
	GHAssertEquals([parser checkLine:@"as abc" error:&error], SIKeywordAs, nil);
	GHAssertEquals([parser checkLine:@"given abc" error:&error], SIKeywordGiven, nil);
	GHAssertEquals([parser checkLine:@"and abc" error:&error], SIKeywordAnd, nil);
	GHAssertEquals([parser checkLine:@"when abc" error:&error], SIKeywordWhen, nil);
	GHAssertEquals([parser checkLine:@"and abc" error:&error], SIKeywordAnd, nil);
	GHAssertEquals([parser checkLine:@"and abc" error:&error], SIKeywordAnd, nil);
	GHAssertEquals([parser checkLine:@"then abc" error:&error], SIKeywordThen, nil);
	GHAssertEquals([parser checkLine:@"and abc" error:&error], SIKeywordAnd, nil);
	GHAssertEquals([parser checkLine:@"and abc" error:&error], SIKeywordAnd, nil);
	GHAssertTrue(error == NULL, nil);
}

#pragma mark Start of story

-(void) testStartOfStoryThenStory {
	GHAssertEquals([parser checkLine:@"story: abc" error:&error], SIKeywordStory, nil);
	GHAssertTrue(error == NULL, nil);
}

-(void) testStartOfStoryThenAs {
	[self checkLine:@"as abc" failsWithMessage:@"You cannot start a story with As"];
}

-(void) testStartOfStoryThenGiven {
	[self checkLine:@"given abc" failsWithMessage:@"You cannot start a story with Given"];
}

-(void) testStartOfStoryThenWhen {
	[self checkLine:@"when abc" failsWithMessage:@"You cannot start a story with When"];
}

-(void) testStartOfStoryThenThen {
	[self checkLine:@"then abc" failsWithMessage:@"You cannot start a story with Then"];
}

-(void) testStartOfStoryThenAnd {
	[self checkLine:@"and abc" failsWithMessage:@"You cannot start a story with And"];
}

#pragma mark Story

-(void) testStoryThenStory {
	[parser checkLine:@"Story:" error:&error];
	[self checkLine:@"story: abc" failsWithMessage:@"Invalid syntax: Story cannot follow Story"];
}

-(void) testStoryThenAs {
	[parser checkLine:@"Story:" error:&error];
	GHAssertEquals([parser checkLine:@"as x" error:&error], SIKeywordAs, nil);
	GHAssertTrue(error == NULL, nil);
}

-(void) testStoryThenGiven {
	[parser checkLine:@"Story:" error:&error];
	GHAssertEquals([parser checkLine:@"given x" error:&error], SIKeywordGiven, nil);
	GHAssertTrue(error == NULL, nil);
}

-(void) testStoryThenWhen {
	[parser checkLine:@"Story:" error:&error];
	[self checkLine:@"when abc" failsWithMessage:@"Invalid syntax: When cannot follow Story"];
}

-(void) testStoryThenThen {
	[parser checkLine:@"Story:" error:&error];
	[self checkLine:@"then abc" failsWithMessage:@"Invalid syntax: Then cannot follow Story"];
}

-(void) testStoryThenAnd {
	[parser checkLine:@"Story:" error:&error];
	[self checkLine:@"and abc" failsWithMessage:@"Invalid syntax: And cannot follow Story"];
}

#pragma mark As

-(void) testAsThenStory {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"as x" error:&error];
	[self checkLine:@"story: abc" failsWithMessage:@"Invalid syntax: Story cannot follow As"];
}

-(void) testAsThenAs {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"as x" error:&error];
	[self checkLine:@"as abc" failsWithMessage:@"Invalid syntax: As cannot follow As"];
}

-(void) testAsThenGiven {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"as x" error:&error];
	GHAssertEquals([parser checkLine:@"given x" error:&error], SIKeywordGiven, nil);
	GHAssertTrue(error == NULL, nil);
}

-(void) testAsThenWhen {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"as x" error:&error];
	GHAssertEquals([parser checkLine:@"when x" error:&error], SIKeywordWhen, nil);
	GHAssertTrue(error == NULL, nil);
}

-(void) testAsThenThen {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"as x" error:&error];
	[self checkLine:@"then abc" failsWithMessage:@"Invalid syntax: Then cannot follow As"];
}

-(void) testAsThenAnd {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"as x" error:&error];
	[self checkLine:@"and abc" failsWithMessage:@"Invalid syntax: And cannot follow As"];
}

#pragma mark Given

-(void) testGivenThenStory {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[self checkLine:@"story: abc" failsWithMessage:@"Invalid syntax: Story cannot follow Given"];
}

-(void) testGivenThenAs {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[self checkLine:@"as abc" failsWithMessage:@"Invalid syntax: As cannot follow Given"];
}

-(void) testGivenThenGiven {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[self checkLine:@"given abc" failsWithMessage:@"Invalid syntax: Given cannot follow Given"];
}

-(void) testGivenThenWhen {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	GHAssertEquals([parser checkLine:@"when x" error:&error], SIKeywordWhen, nil);
	GHAssertTrue(error == NULL, nil);
}

-(void) testGivenThenThen {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	GHAssertEquals([parser checkLine:@"then x" error:&error], SIKeywordThen, nil);
	GHAssertTrue(error == NULL, nil);
}

-(void) testGivenThenAnd {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	GHAssertEquals([parser checkLine:@"and x" error:&error], SIKeywordAnd, nil);
	GHAssertTrue(error == NULL, nil);
}

#pragma mark When

-(void) testWhenThenStory {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[parser checkLine:@"when x" error:&error];
	[self checkLine:@"story: abc" failsWithMessage:@"Invalid syntax: Story cannot follow When"];
}

-(void) testWhenThenAs {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[parser checkLine:@"when x" error:&error];
	[self checkLine:@"as abc" failsWithMessage:@"Invalid syntax: As cannot follow When"];
}

-(void) testWhenThenGiven {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[parser checkLine:@"when x" error:&error];
	[self checkLine:@"given abc" failsWithMessage:@"Invalid syntax: Given cannot follow When"];
}

-(void) testWhenThenWhen {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[parser checkLine:@"when x" error:&error];
	[self checkLine:@"given abc" failsWithMessage:@"Invalid syntax: Given cannot follow When"];
}

-(void) testWhenThenThen {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[parser checkLine:@"when x" error:&error];
	GHAssertEquals([parser checkLine:@"then x" error:&error], SIKeywordThen, nil);
	GHAssertTrue(error == NULL, nil);
}

-(void) testWhenThenAnd {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[parser checkLine:@"when x" error:&error];
	GHAssertEquals([parser checkLine:@"and x" error:&error], SIKeywordAnd, nil);
	GHAssertTrue(error == NULL, nil);
}

#pragma mark Then

-(void) testThenThenStory {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[parser checkLine:@"then x" error:&error];
	GHAssertEquals([parser checkLine:@"story: x" error:&error], SIKeywordStory, nil);
}

-(void) testThenThenAs {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[parser checkLine:@"then x" error:&error];
	[self checkLine:@"as abc" failsWithMessage:@"Invalid syntax: As cannot follow Then"];
}

-(void) testThenThenGiven {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[parser checkLine:@"then x" error:&error];
	[self checkLine:@"given abc" failsWithMessage:@"Invalid syntax: Given cannot follow Then"];
}

-(void) testThenThenWhen {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[parser checkLine:@"then x" error:&error];
	[self checkLine:@"when abc" failsWithMessage:@"Invalid syntax: When cannot follow Then"];
}

-(void) testThenThenThen {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[parser checkLine:@"then x" error:&error];
	[self checkLine:@"then abc" failsWithMessage:@"Invalid syntax: Then cannot follow Then"];
}

-(void) testThenThenAnd {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[parser checkLine:@"then x" error:&error];
	GHAssertEquals([parser checkLine:@"and x" error:&error], SIKeywordAnd, nil);
	GHAssertTrue(error == NULL, nil);
}

-(void) testThenAndAndThenStory {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[parser checkLine:@"then x" error:&error];
	[parser checkLine:@"and x" error:&error];
	[parser checkLine:@"and x" error:&error];
	GHAssertEquals([parser checkLine:@"story: x" error:&error], SIKeywordStory, nil);
}


#pragma mark And

-(void) testAndThenStory {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[parser checkLine:@"and x" error:&error];
	[self checkLine:@"story: abc" failsWithMessage:@"Invalid syntax: Story cannot follow Given"];
}

-(void) testAndThenAs {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[parser checkLine:@"and x" error:&error];
	[self checkLine:@"as abc" failsWithMessage:@"Invalid syntax: As cannot follow Given"];
}

-(void) testAndThenGiven {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[parser checkLine:@"and x" error:&error];
	[self checkLine:@"given abc" failsWithMessage:@"Invalid syntax: Given cannot follow Given"];
}

-(void) testAndThenWhen {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[parser checkLine:@"and x" error:&error];
	GHAssertEquals([parser checkLine:@"and x" error:&error], SIKeywordAnd, nil);
	GHAssertTrue(error == NULL, nil);
}

-(void) testAndThenThen {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[parser checkLine:@"and x" error:&error];
	GHAssertEquals([parser checkLine:@"and x" error:&error], SIKeywordAnd, nil);
	GHAssertTrue(error == NULL, nil);
}

-(void) testAndThenAnd {
	[parser checkLine:@"Story:" error:&error];
	[parser checkLine:@"given x" error:&error];
	[parser checkLine:@"and x" error:&error];
	GHAssertEquals([parser checkLine:@"and x" error:&error], SIKeywordAnd, nil);
	GHAssertTrue(error == NULL, nil);
}

#pragma mark - Helpers

-(void) checkLine:(NSString *) line failsWithMessage:(NSString *) msg {
	GHAssertEquals([parser checkLine:line error:&error], SIKeywordUnknown, nil);
   GHAssertEquals(error.code, SIErrorInvalidStorySyntax, nil);
	GHAssertEqualStrings(error.userInfo[NSLocalizedFailureReasonErrorKey], msg, nil);
}


@end
