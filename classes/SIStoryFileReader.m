//
//  FileSystemStoryReader.m
//  Simon
//
//  Created by Derek Clarkson on 5/30/11.
//  Copyright 2011. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import <dUsefulStuff/NSObject+dUsefulStuff.h>

#import "SIStoryFileReader.h"
#import "SIConstants.h"
#import "NSString+Simon.h"

@interface SIStoryFileReader()
-(BOOL) readFile:(NSString *) filename error:(NSError **) error;
-(BOOL) processLine:(NSString *) line error:(NSError **) error;
-(BOOL) checkSyntaxWithKeyword:(SIKeyword) nextKeyword error:(NSError **) error;
-(SIKeyword) keywordFromLine:(NSString *) line error:(NSError **) error;
-(void) createNewStoryWithTitle:(NSString *) title;
-(NSString *)failureReasonWithContent:(NSString *) content;

@end

@implementation SIStoryFileReader

@synthesize storySources = storySources_;

-(void) dealloc {
	DC_LOG(@"Deallocing");
	self.storySources = nil;
	DC_DEALLOC(currentSource);
	DC_DEALLOC(trimChars);
	[super dealloc];
}

-(id) init {
	self = [super init];
	if (self) {
		trimChars = [[NSMutableCharacterSet whitespaceCharacterSet] retain];
		[(NSMutableCharacterSet *)trimChars formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@".,;:!?"]];
	}
	return self;
}

-(NSArray *) readStorySources:(NSError **) error {
	
	NSArray *files = [[NSBundle mainBundle] pathsForResourcesOfType:STORY_EXTENSION inDirectory:nil];
	self.storySources = [NSMutableArray arrayWithCapacity:[files count]];
	
	for (NSString *file in files) {
		if (![self readFile:file error:error]) {
			DC_LOG(@"Error reading story file: %@", [*error localizedFailureReason]);
			return nil;
		}
	}
	
	DC_LOG(@"Number of stories loaded: %i", [(NSArray *)[self.storySources valueForKeyPath:@"@unionOfArrays.stories"] count]);
	return self.storySources;
}

-(BOOL) readFile:(NSString *) filename error:(NSError **) error {
	
	// Add the file as source.
	currentSource = [[SIStorySource alloc] init];
	currentSource.source = filename;
	[(NSMutableArray *)self.storySources addObject:currentSource];
	
	// Read the file.
	DC_LOG(@"Reading file: %@", filename);
	NSString *contents = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:error];
	if (contents == nil) {
		DC_LOG(@"Failed to read file %@", filename);
		return NO;
	}
	
	// Break it up and process the lines.
	priorKeyword = SIKeywordStartOfFile;
	NSUInteger lineNbr = 0;
	for (NSString * line in [contents componentsSeparatedByString:@"\n"]) {
		currentLineNumber = ++lineNbr;
		if (![self processLine: line error:error]) {
			// Error reading the source.
			return NO;
		}
	}
	
	DC_DEALLOC(currentSource);
	return YES;
	
}


-(BOOL) processLine:(NSString *) line 
				  error:(NSError **) error {
	
	DC_LOG(@"Line: %@", line);
	
	// Trim whitespace and trailing punctuation.
	NSString *cleanLine = [line stringByTrimmingCharactersInSet:trimChars];
	
	// If there is nothing left or it starts with a comment char then ignore it.
	if ([cleanLine length] == 0 || [cleanLine hasPrefix:@"#"]) {
		return YES;
	}
	
	// Attempt to figure out what the keyword is.
	SIKeyword keyword = [self keywordFromLine:cleanLine error:error];
	if (keyword == SIKeywordUnknown) {
		DC_LOG(@"Detected unknown keyword in step: %@", cleanLine);
		NSString *msg = [self failureReasonWithContent:[NSString stringWithFormat:@"Story syntax error, unknown keyword on step \"%@\"", cleanLine]];
		[self setError:error code:SIErrorInvalidKeyword errorDomain:SIMON_ERROR_DOMAIN shortDescription:@"Story syntax error, unknown keyword" failureReason:msg];
		return NO;
	}
	
	// Check syntax.
	if (![self checkSyntaxWithKeyword:keyword error:error]) {
		return NO;
	}
	
	// Valid so store the new keyword as the prior.
	priorKeyword = keyword;
	
	// Create a new story if its the story keyword and return without add a step.
	if (keyword == SIKeywordStory) {
		[self createNewStoryWithTitle:cleanLine];
		return YES;
	}
	
	// Now add the step to the current story.
	DC_LOG(@"Adding step: %@", cleanLine);
	SIStory *story = [currentSource.stories lastObject];
	[story createStepWithKeyword:keyword command:cleanLine];
	
	return YES;
}

-(SIKeyword) keywordFromLine:(NSString *) line error:(NSError **) error {
	NSString *firstWord = nil;
	BOOL foundWord = [[NSScanner scannerWithString:line] 
							scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] 
							intoString:&firstWord];
	
	if (!foundWord) {
		NSString *message = [self failureReasonWithContent:@"Each line of a story must start with a valid keyword (Story, Given, Then, As or And) or a comment."];
		[self setError:error 
					 code:SIErrorInvalidStorySyntax 
			errorDomain:SIMON_ERROR_DOMAIN 
	 shortDescription:@"Story syntax error, step does not begin with a word" 
		 failureReason:message];
		return SIKeywordUnknown;
	}
	
	SIKeyword keyword = [firstWord keywordFromString];
	if (keyword == SIKeywordUnknown) {
		NSString *message = [self failureReasonWithContent:[NSString stringWithFormat:@"Each line of a story must start with a valid keyword (Given, Then, As or And) or a comment. \"%@\" is not a keyword.", firstWord]];
		[self setError:error 
					 code:SIErrorInvalidStorySyntax 
			errorDomain:SIMON_ERROR_DOMAIN 
	 shortDescription:[NSString stringWithFormat:@"Story syntax error, unknown keyword %@", firstWord] 
		 failureReason:message];
	}
	return keyword;
}

-(BOOL) checkSyntaxWithKeyword:(SIKeyword) nextKeyword error:(NSError **) error {
	
	// Validate the order of keywords.
	DC_LOG(@"Syntax check %@ -> %@", 
			 [NSString stringFromKeyword: priorKeyword],
			 [NSString stringFromKeyword: nextKeyword]);
	
	// Cross reference the prior keyword and current keyword to decide
	// whether the syntax is ok.
	switch (priorKeyword) {
			
		case SIKeywordStartOfFile:
			if (nextKeyword != SIKeywordStory) {
				NSString *message = [self failureReasonWithContent:@"Incorrect keyword order, the \"Story:\" keyword must be the first keyword."];
				[self setError:error 
							 code:SIErrorInvalidStorySyntax 
					errorDomain:SIMON_ERROR_DOMAIN 
			 shortDescription:@"Incorrect keyword order" 
				 failureReason:message];
				return NO;
			}
			break;
			
		case SIKeywordStory: // SIKeywordStory so no prior.
			if (nextKeyword != SIKeywordGiven && nextKeyword != SIKeywordAs) {
				NSString *message = [self failureReasonWithContent:@"Incorrect keyword order, \"As\" or \"Given\" must appear after \"Story:\""];
				[self setError:error 
							 code:SIErrorInvalidStorySyntax 
					errorDomain:SIMON_ERROR_DOMAIN 
			 shortDescription:@"Incorrect keyword order" 
				 failureReason:message];
				return NO;
			}
			break;
			
		case SIKeywordGiven:
			if (nextKeyword == SIKeywordGiven || nextKeyword == SIKeywordAs || nextKeyword == SIKeywordStory) {
				NSString *message = [self failureReasonWithContent:@"Incorrect keyword order, only \"Then\", \"And\" or \"Story:\" can appear after \"Given\""];
				[self setError:error 
							 code:SIErrorInvalidStorySyntax 
					errorDomain:SIMON_ERROR_DOMAIN 
			 shortDescription:@"Incorrect keyword order" 
				 failureReason:message];
				return NO;
			}
			break;
			
		case SIKeywordAs:
			if (nextKeyword != SIKeywordGiven && nextKeyword != SIKeywordThen) {
				NSString *message = [self failureReasonWithContent:@"Incorrect keyword order, only \"Given\" or \"Then\" can appear after \"As\""];
				[self setError:error 
							 code:SIErrorInvalidStorySyntax 
					errorDomain:SIMON_ERROR_DOMAIN 
			 shortDescription:@"Incorrect keyword order" 
				 failureReason:message];
				return NO;
			} break;
			
		case SIKeywordThen:
			if (nextKeyword != SIKeywordAnd && nextKeyword != SIKeywordStory) {
				NSString *message = [self failureReasonWithContent:[NSString stringWithFormat:@"Incorrect keyword order, \"%@\" cannot appear after \"Then\"", [NSString stringFromKeyword:nextKeyword]]];
				[self setError:error 
							 code:SIErrorInvalidStorySyntax 
					errorDomain:SIMON_ERROR_DOMAIN 
			 shortDescription:@"Incorrect keyword order" 
				 failureReason:message];
				return NO;
			}
			
			break;
			
		default: // SIKeywordUnknown
			break;
	}
	
	return YES;

}


-(void) createNewStoryWithTitle:(NSString *) title {
	
	// Create the new one and store it in the return array.
	DC_LOG(@"Creating new story");
	SIStory *story = [[SIStory alloc] init];
	[currentSource addStory:story];
	
	// Store the title.
	NSString *storyTitle = [[title substringFromIndex: 5] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if ([storyTitle hasPrefix:@":"]) {
		storyTitle = [[storyTitle substringFromIndex: 1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	}
	DC_LOG(@"Title: %@", storyTitle);
	story.title = storyTitle;
	[story release];
}

-(NSString *)failureReasonWithContent:(NSString *) content {
	return [NSString stringWithFormat:@"%@[line %i]: %@", [currentSource.source lastPathComponent], currentLineNumber, content];
}


@end
