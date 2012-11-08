//
//  SIStorySyntaxParserTests.m
//  Simon
//
//  Created by Derek Clarkson on 1/11/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIStorySyntaxParser.h>
#import <Simon/SIConstants.h>

@interface SIStorySyntaxParserTests : GHTestCase {
	@private
	SIStorySyntaxParser *parser;
	NSError *error;
}

-(void) checkLine:(NSString *) line lineNumber:(int) lineNumber failsWithMessage:(NSString *) msg;

@end

@implementation SIStorySyntaxParserTests

-(void) setUp {
	SIStorySource *source = [[[SIStorySource alloc] init] autorelease];
	source.source = @"abc.stories";
	parser = [[SIStorySyntaxParser alloc] initWithSource:source];
	error = NULL;
}

-(void) tearDown {
	DC_DEALLOC(parser);
}

-(void) testUnknownKeyword {
	[self checkLine:@"xyz abc" lineNumber:1 failsWithMessage:@"abc.stories[line 1]: Each line of a story must start with a valid keyword (As, Given, When, Then or And) or a comment. \"xyz\" is not a keyword."];
}

-(void) testStartOfStoryThenStory {
	GHAssertTrue([parser checkLine:@"story: abc" lineNumber:1 error:&error], nil);
	GHAssertTrue(error == NULL, nil);
}

-(void) testStartOfStoryThenAs {
	[self checkLine:@"as abc" lineNumber:1 failsWithMessage:@"abc.stories[line 1]: You cannot start a story with As"];
}

-(void) testStartOfStoryThenGiven {
	[self checkLine:@"given abc" lineNumber:1 failsWithMessage:@"abc.stories[line 1]: You cannot start a story with Given"];
}

-(void) testStartOfStoryThenWhen {
	[self checkLine:@"when abc" lineNumber:1 failsWithMessage:@"abc.stories[line 1]: You cannot start a story with When"];
}

-(void) testStartOfStoryThenThen {
	[self checkLine:@"then abc" lineNumber:1 failsWithMessage:@"abc.stories[line 1]: You cannot start a story with Then"];
}

-(void) testStartOfStoryThenAnd {
	[self checkLine:@"and abc" lineNumber:1 failsWithMessage:@"abc.stories[line 1]: You cannot start a story with And"];
}

-(void) testStoryThenStory {
	[parser checkLine:@"Story:" lineNumber:1 error:&error];
	[self checkLine:@"story: abc" lineNumber:2 failsWithMessage:@"abc.stories[line 1]: You cannot start a story with As"];
}

-(void) testStoryThenAs {
	[parser checkLine:@"Story:" lineNumber:1 error:&error];
	GHAssertTrue([parser checkLine:@"as x" lineNumber:2 error:&error], nil);
	GHAssertTrue(error == NULL, nil);
}

-(void) testStoryThenGiven {
	[parser checkLine:@"Story:" lineNumber:1 error:&error];
	GHAssertTrue([parser checkLine:@"given x" lineNumber:2 error:&error], nil);
	GHAssertTrue(error == NULL, nil);
}

-(void) testStoryThenWhen {
	[parser checkLine:@"Story:" lineNumber:1 error:&error];
	[self checkLine:@"when abc" lineNumber:2 failsWithMessage:@"abc.stories[line 1]: You cannot start a story with When"];
}

-(void) testStoryThenThen {
	[parser checkLine:@"Story:" lineNumber:1 error:&error];
	[self checkLine:@"then abc" lineNumber:2 failsWithMessage:@"abc.stories[line 1]: You cannot start a story with Then"];
}

-(void) testStoryThenAnd {
	[parser checkLine:@"Story:" lineNumber:1 error:&error];
	[self checkLine:@"and abc" lineNumber:2 failsWithMessage:@"abc.stories[line 1]: You cannot start a story with And"];
}

#pragma mark - Helpers

-(void) checkLine:(NSString *) line lineNumber:(int) lineNumber failsWithMessage:(NSString *) msg {
	GHAssertFalse([parser checkLine:line lineNumber:1 error:&error], nil);
   GHAssertEquals(error.code, SIErrorInvalidStorySyntax, nil);
	GHAssertEqualStrings(error.userInfo[NSLocalizedFailureReasonErrorKey], msg, nil);
}


@end
