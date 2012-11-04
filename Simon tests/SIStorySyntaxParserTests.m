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

-(void) checkLine:(NSString *) line failsWithMessage:(NSString *) msg;

@end

@implementation SIStorySyntaxParserTests

-(void) setUp {
	parser = [[SIStorySyntaxParser alloc] init];
	error = NULL;
}

-(void) tearDown {
	DC_DEALLOC(parser);
	DC_DEALLOC(error);
}

-(void) testStartOfStoryThenStory {
	GHAssertTrue([parser checkLine:@"story: abc" lineNumber:1 error:&error], nil);
}

-(void) testStartOfStoryThenAs {
	[self checkLine:@"as abc" failsWithMessage:@"as cannot follow story"];
}

-(void) testStartOfStoryThenGiven {
	[self checkLine:@"given abc" failsWithMessage:@"given cannot follow story"];
}

-(void) testStartOfStoryThenWhen {
	[self checkLine:@"when abc" failsWithMessage:@"when cannot follow story"];
}

-(void) testStartOfStoryThenThen {
	[self checkLine:@"then abc" failsWithMessage:@"then cannot follow story"];
}

-(void) testStartOfStoryThenAnd {
	[self checkLine:@"and abc" failsWithMessage:@"and cannot follow story"];
}

-(void) checkLine:(NSString *) line failsWithMessage:(NSString *) msg {
	GHAssertFalse([parser checkLine:line lineNumber:1 error:&error], nil);
   GHAssertEquals(error.code, SIErrorInvalidStorySyntax, nil);
	NSDictionary *userInfo = error.userInfo;
	GHAssertEqualStrings(userInfo[NSLocalizedFailureReasonErrorKey], msg, nil);
}


@end
