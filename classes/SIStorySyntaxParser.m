//
//  SIStorySyntaxParser.m
//  Simon
//
//  Created by Derek Clarkson on 1/11/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import <dUsefulStuff/NSObject+dUsefulStuff.h>

#import <Simon/SIConstants.h>
#import "SIStorySyntaxParser.h"
#import <Simon/NSString+Simon.h>

@interface SIStorySyntaxParser () {
@private
	SIKeyword _previousKeyword;
	NSDictionary *_syntaxRules;
}
-(SIKeyword) keywordForLine:(NSString *) line error:(NSError **) error;
@end

@implementation SIStorySyntaxParser

-(void) dealloc {
	DC_DEALLOC(_syntaxRules);
	[super dealloc];
}

-(id) init {
	self = [super init];
	if (self) {
		_previousKeyword = SIKeywordStartOfStory; // No lines read.
		// Syntax rules. Dictionary with the from word as the key and array of next words as the value.
		_syntaxRules = [@{
							 @(SIKeywordStartOfStory):@[@(SIKeywordStory)],
							 @(SIKeywordStory):@[@(SIKeywordGiven), @(SIKeywordAs)],
							 @(SIKeywordAs):@[@(SIKeywordGiven), @(SIKeywordWhen)],
							 @(SIKeywordGiven):@[@(SIKeywordWhen), @(SIKeywordThen), @(SIKeywordAnd)],
							 @(SIKeywordWhen):@[@(SIKeywordThen), @(SIKeywordAnd)],
							 @(SIKeywordThen):@[@(SIKeywordAnd), @(SIKeywordStory)]
							 } retain];
	}
	return self;
}

-(SIKeyword) checkLine:(NSString *) line error:(NSError **) error {
	
	// Get the keyword.
	SIKeyword keyword = [self keywordForLine:line error:error];
	if (keyword == SIKeywordUnknown) {
		return SIKeywordUnknown;
	}
	
	// Validate and populate the error if it's not found.
	if (![_syntaxRules[@(_previousKeyword)] containsObject:@(keyword)]) {
		
		if (_previousKeyword == SIKeywordStartOfStory) {
			[self setError:error
						 code:SIErrorInvalidStorySyntax
				errorDomain:SIMON_ERROR_DOMAIN
		 shortDescription:@"Invalid syntax"
			 failureReason:[NSString stringWithFormat:@"You cannot start a story with %@", [NSString stringFromSIKeyword:keyword]]];
		} else {
			[self setError:error
						 code:SIErrorInvalidStorySyntax
				errorDomain:SIMON_ERROR_DOMAIN
		 shortDescription:@"Invalid syntax"
			 failureReason:[NSString stringWithFormat:@"Invalid syntax: %@ cannot follow %@", [NSString stringFromSIKeyword:keyword], [NSString stringFromSIKeyword:_previousKeyword]]];
		}
		
		return SIKeywordUnknown;
	}
	
	// If the keyword is And then don't remember it as the previous.
	// Remember the keyword and exit.
	if (keyword != SIKeywordAnd) {
		_previousKeyword = keyword;
	}
	return keyword;
}

-(SIKeyword) keywordForLine:(NSString *) line error:(NSError **) error {
	
	NSString *firstWord = nil;
	BOOL foundWord = [[NSScanner scannerWithString:line]
							scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet]
							intoString:&firstWord];
	
	if (!foundWord) {
		[self setError:error
					 code:SIErrorInvalidKeyword
			errorDomain:SIMON_ERROR_DOMAIN
	 shortDescription:@"Story syntax error, step does not begin with a word"
		 failureReason:@"Each line of a story must start with a valid keyword (As, Story, Given, When, Then or And) or a comment."];
		return SIKeywordUnknown;
	}
	
	SIKeyword keyword = [firstWord siKeyword];
	if (keyword == SIKeywordUnknown) {
		[self setError:error
					 code:SIErrorInvalidKeyword
			errorDomain:SIMON_ERROR_DOMAIN
	 shortDescription:[NSString stringWithFormat:@"Story syntax error, unknown keyword %@", firstWord]
		 failureReason:[NSString stringWithFormat:@"Each line of a story must start with a valid keyword (As, Given, When, Then or And) or a comment. \"%@\" is not a keyword.", firstWord]];
	}
	return keyword;
}

@end
