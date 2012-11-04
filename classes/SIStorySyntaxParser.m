//
//  SIStorySyntaxParser.m
//  Simon
//
//  Created by Derek Clarkson on 1/11/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIStorySyntaxParser.h"
#import <Simon/SIConstants.h>
#import <dUsefulStuff/DCCommon.h>
#import <dUsefulStuff/NSObject+dUsefulStuff.h>
#import <Simon/NSString+Simon.h>

// Array which validates the order of lines in a story.
static BOOL validSyntax[][7] = {
	{NO, YES, NO, NO, NO, NO, NO}, // Start of file
	{NO, NO, YES, YES, YES, NO, NO}, // Story
	{NO, NO, NO, YES, YES, NO, NO}, // As
	{NO, NO, NO, NO, YES, YES, YES}, // Given
	{NO, NO, NO, NO, NO, YES, YES}, // When
	{NO, NO, NO, NO, NO, NO, YES}, // Then
	{NO, NO, NO, NO, NO, NO, YES} // And
};

@interface SIStorySyntaxParser () {
@private
	SIStorySource *_source;
	SIKeyword _previousKeyword;
}
-(SIKeyword) keywordForLine:(NSString *) line lineNumber:(NSInteger) lineNumber error:(NSError **) error;
-(BOOL) setError:(NSError **) error
 withShortReason:(NSString *) shortReason
	failureReason:(NSString *) failureReason
		lineNumber:(NSInteger) lineNumber;
@end

@implementation SIStorySyntaxParser

-(void) dealloc {
	DC_DEALLOC(_source);
	[super dealloc];
}

-(id) initWithSource:(SIStorySource *) source {
	self = [super init];
	if (self) {
		_source = [source retain];
		_previousKeyword = 0; // No lines read.
	}
	return self;
}

-(BOOL) checkLine:(NSString *) line lineNumber:(NSInteger) lineNumber error:(NSError **) error {
	
	// Get the keyword.
	SIKeyword keyword = [self keywordForLine:line lineNumber:lineNumber error:error];
	if (keyword == SIKeywordUnknown) {
		return NO;
	}
	
	// Validate and populate the error if it's not found.
	if (validSyntax[_previousKeyword][keyword]) {
		[self setError:error
	  withShortReason:@"Invalid syntax"
		 failureReason:[NSString stringWithFormat:@"Invalid syntax: %@ cannot follow %@", [NSString stringFromSIKeyword:keyword], [NSString stringFromSIKeyword:_previousKeyword]]
			 lineNumber:lineNumber];
		return NO;
	}

	// Remember the keyword and exit.
	_previousKeyword = keyword;
	return YES;
}

-(SIKeyword) keywordForLine:(NSString *) line lineNumber:(NSInteger) lineNumber error:(NSError **) error {
	
	NSString *firstWord = nil;
	BOOL foundWord = [[NSScanner scannerWithString:line]
							scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet]
							intoString:&firstWord];
	
	if (!foundWord) {
		[self setError:error
	  withShortReason:@"Story syntax error, step does not begin with a word"
		 failureReason:@"Each line of a story must start with a valid keyword (As, Story, Given, When, Then or And) or a comment."
			 lineNumber:lineNumber];
		return SIKeywordUnknown;
	}
	
	SIKeyword keyword = [firstWord siKeyword];
	if (keyword == SIKeywordUnknown) {
		[self setError:error
	  withShortReason:[NSString stringWithFormat:@"Story syntax error, unknown keyword %@", firstWord]
		 failureReason:[NSString stringWithFormat:@"Each line of a story must start with a valid keyword (As, Given, When, Then or And) or a comment. \"%@\" is not a keyword.", firstWord]
			 lineNumber:lineNumber];
	}
	return keyword;
}

-(BOOL) setError:(NSError **) error
 withShortReason:(NSString *) shortReason
	failureReason:(NSString *) failureReason
		lineNumber:(NSInteger) lineNumber {
	
	NSString * finalfailureReason = [NSString stringWithFormat:@"%@[line %i]: %@", [_source.source lastPathComponent], lineNumber, failureReason];
	[self setError:error
				 code:SIErrorInvalidStorySyntax
		errorDomain:SIMON_ERROR_DOMAIN
 shortDescription:shortReason
	 failureReason:finalfailureReason];
	return YES;
}

@end
