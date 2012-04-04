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
-(BOOL) processLine:(NSString *) line 
				  error:(NSError **) error;
-(void) createNewStoryWithTitle:(NSString *) title;
-(SIKeyword) keywordFromLine:(NSString *) line 
							  error:(NSError **) error;
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
	self.storySources = [NSMutableArray array];

	for (NSString *file in files) {
		
		priorKeyword = SIKeywordStartOfFile;
		
		// Add the file as source.
		currentSource = [[SIStorySource alloc] init];
		currentSource.source = file;
		[(NSMutableArray *)self.storySources addObject:currentSource];
		
		// Read the file.
		DC_LOG(@"Reading file: %@", file);
		NSString *contents = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:error];
		if (contents == nil) {
			DC_LOG(@"Failed to read file %@", file);
			return nil;
		}
		
		// Break it up and process the lines.
		NSUInteger lineNbr = 0;
		for (NSString * line in [contents componentsSeparatedByString:@"\n"]) {
			currentLineNumber = ++lineNbr;
			if (![self processLine: line error:error]) {
				// Error reading the source.
				return nil;
			}
		}
		
		DC_DEALLOC(currentSource);
	}

	DC_LOG(@"Number of stories loaded: %i", [(NSArray *)[self.storySources valueForKeyPath:@"@unionOfArrays.stories"] count]);
	return self.storySources;
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
	
	// Validate the order of keywords.
	DC_LOG(@"Syntax check %@ -> %@", 
			 [NSString stringFromKeyword: priorKeyword],
			 [NSString stringFromKeyword: keyword]);
	
	// Cross reference the prior keyword and current keyword to decide
	// whether the syntax is ok.
	switch (priorKeyword) {
			
		case SIKeywordStartOfFile:
			if (keyword != SIKeywordStory) {
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
			if (keyword != SIKeywordGiven && keyword != SIKeywordAs) {
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
			if (keyword == SIKeywordGiven || keyword == SIKeywordAs || keyword == SIKeywordStory) {
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
			if (keyword != SIKeywordGiven && keyword != SIKeywordThen) {
				NSString *message = [self failureReasonWithContent:@"Incorrect keyword order, only \"Given\" or \"Then\" can appear after \"As\""];
				[self setError:error 
							 code:SIErrorInvalidStorySyntax 
					errorDomain:SIMON_ERROR_DOMAIN 
			 shortDescription:@"Incorrect keyword order" 
				 failureReason:message];
				return NO;
			} break;
			
		case SIKeywordThen:
			if (keyword != SIKeywordAnd && keyword != SIKeywordStory) {
				NSString *message = [self failureReasonWithContent:[NSString stringWithFormat:@"Incorrect keyword order, \"%@\" cannot appear after \"Then\"", [NSString stringFromKeyword:keyword]]];
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


-(void) createNewStoryWithTitle:(NSString *) title {
	
	// Create the new one and store it in the return array.
	DC_LOG(@"Creating new story");
	SIStory *story = [[[SIStory alloc] init] autorelease];
	[currentSource.stories addObject:story];
	
	// Store the title.
	NSString *storyTitle = [[title substringFromIndex: 5] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if ([storyTitle hasPrefix:@":"]) {
		storyTitle = [[storyTitle substringFromIndex: 1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	}
	DC_LOG(@"Title: %@", storyTitle);
	story.title = storyTitle;
}

-(NSString *)failureReasonWithContent:(NSString *) content {
	return [NSString stringWithFormat:@"%@[line %i]: %@", [currentSource.source lastPathComponent], currentLineNumber, content];
}


@end
