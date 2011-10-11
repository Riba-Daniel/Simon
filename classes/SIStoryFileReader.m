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
#import "SIStorySource.h"

@interface SIStoryFileReader()
-(BOOL) processNextLine:(NSString *) line source:(SIStorySource *) source error:(NSError **) error;
-(void) createNewStoryForSource:(SIStorySource *) source withTitle:(NSString *) title;
-(SIKeyword) keywordFromLine:(NSString *) line error:(NSError **) error;
-(SIKeyword) priorKeywordFromStory:(SIStory *) story;
-(void) mainInit;
@end

@implementation SIStoryFileReader
@synthesize files;

-(id) init {
	self = [super init];
	if (self) {
		[self mainInit];
		self.files = [[NSBundle mainBundle] pathsForResourcesOfType:STORY_EXTENSION inDirectory:nil];
	}
	return self;
}

-(id) initWithFileName:(NSString *) fileName {
	self = [super init];
	if (self) {
		[self mainInit];
		NSString * file = [[NSBundle mainBundle] pathForResource:fileName ofType:STORY_EXTENSION];
		DC_LOG(@"Found file %@", file);
		if (file == nil) {
			NSException* myException = [NSException
												 exceptionWithName:@"FileNotFoundException"
												 reason:@"File Not Found on System"
												 userInfo:nil];
			@throw myException;
		}
		self.files = [NSArray arrayWithObject:file];
	}
	return self;
}

-(void) mainInit {
	trimChars = [[NSMutableCharacterSet whitespaceCharacterSet] retain];
	[(NSMutableCharacterSet *)trimChars formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@".,;:!?"]];
}

-(NSArray *) readStorySources:(NSError **) error {
	
	NSMutableArray * storySources = [[[NSMutableArray alloc] init] autorelease];
	
	for (NSString * file in self.files) {
		
		// Add the file as source.
		SIStorySource *source = [[[SIStorySource alloc] init] autorelease];
		source.source = file;
		[storySources addObject:source];
		
		// Read the file.
		DC_LOG(@"Reading file: %@", file);
		NSString *contents = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:error];
		if (contents == nil) {
			DC_LOG(@"Failed to read file %@", file);
			return nil;
		}
		
		// Break it up and process the lines.
		for (NSString * line in [contents componentsSeparatedByString:@"\n"]) {
			if (![self processNextLine: line source:source error:error]) {
				return nil;
			}
		}
	}
	
	return storySources;
}

-(BOOL) processNextLine:(NSString *) line source:(SIStorySource *) source error:(NSError **) error {
	
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
		if (error != NULL) {
			*error = [self errorForCode:SIErrorInvalidKeyword 
								 errorDomain:SIMON_ERROR_DOMAIN 
						  shortDescription:@"Story syntax error, unknown keyword" 
							  failureReason:[NSString stringWithFormat:@"Story syntax error in %@, unknown keyword on step \"%@\"", source.source, cleanLine]];
		}
		return NO;
	}
	
	// Validate the order of keywords.
	SIKeyword priorKeyword = [self priorKeywordFromStory:[source.stories lastObject]];
	DC_LOG(@"Syntax check %@ -> %@", 
			 [NSString stringFromKeyword: priorKeyword],
			 [NSString stringFromKeyword: keyword]);
	
	// Cross reference the prior keyword and current keyword to decide
	// whether the syntax is ok.
	switch (priorKeyword) {
			
		case SIKeywordStartOfFile:
			if (keyword != SIKeywordStory) {
				[self setError:error 
							 code:SIErrorInvalidStorySyntax 
					errorDomain:SIMON_ERROR_DOMAIN 
			 shortDescription:@"Incorrect keyword order" 
				 failureReason:@"Incorrect keyword order, the Story: keyword must be the first keyword."];
				return NO;
			}
			break;
			
		case SIKeywordStory: // SIKeywordStory so no prior.
			if (keyword != SIKeywordGiven && keyword != SIKeywordAs) {
				[self setError:error 
							 code:SIErrorInvalidStorySyntax 
					errorDomain:SIMON_ERROR_DOMAIN 
			 shortDescription:@"Incorrect keyword order" 
				 failureReason:@"Incorrect keyword order, As or Given must appear after Story:"];
				return NO;
			}
			break;
			
		case SIKeywordGiven:
			if (keyword == SIKeywordGiven || keyword == SIKeywordAs || keyword == SIKeywordStory) {
				[self setError:error 
							 code:SIErrorInvalidStorySyntax 
					errorDomain:SIMON_ERROR_DOMAIN 
			 shortDescription:@"Incorrect keyword order" 
				 failureReason:@"Incorrect keyword order, only Then, And or Story: can appear after Given"];
				return NO;
			}
			break;
			
		case SIKeywordAs:
			if (keyword != SIKeywordGiven && keyword != SIKeywordThen) {
				[self setError:error 
							 code:SIErrorInvalidStorySyntax 
					errorDomain:SIMON_ERROR_DOMAIN 
			 shortDescription:@"Incorrect keyword order" 
				 failureReason:@"Incorrect keyword order, only Given or Then can appear after As"];
				return NO;
			} break;
			
		case SIKeywordThen:
			if (keyword != SIKeywordAnd && keyword != SIKeywordStory) {
				[self setError:error 
							 code:SIErrorInvalidStorySyntax 
					errorDomain:SIMON_ERROR_DOMAIN 
			 shortDescription:@"Incorrect keyword order" 
				 failureReason:[NSString stringWithFormat:@"Incorrect keyword order, %@ cannot appear after Then", [NSString stringFromKeyword:keyword]]];
				return NO;
			}
			
			break;
			
		default: // SIKeywordUnknown
			break;
	}
	
	// Create a new story if its the story keyword and return without add a step.
	if (keyword == SIKeywordStory) {
		[self createNewStoryForSource: source withTitle:cleanLine];
		return YES;
	}
	
	// Now add the step to the current story.
	DC_LOG(@"Adding step: %@", cleanLine);
	SIStory *story = [source.stories lastObject];
	[story createStepWithKeyword:keyword command:cleanLine];
	
	return YES;
}

/**
 * Searches backwards through the steps, ignoring And steps to find the previous keyword.
 * Returns SIKeywordUnknown if it doesn't find anything.
 */
-(SIKeyword) priorKeywordFromStory:(SIStory *) story {

	// If there is no current story then it's the first story so return none.
	if (story == nil) {
		return SIKeywordStartOfFile;
	}
	
	// Go backwards to find the prior keyword.
	for (int i = [story.steps count] - 1; i >= 0; i--) {
		SIStep * step = [story.steps objectAtIndex:i]; 
		if (step.keyword == SIKeywordAnd) {
			continue;
		}
		return step.keyword;
	}
	return SIKeywordStory;
}


-(SIKeyword) keywordFromLine:(NSString *) line error:(NSError **) error {
	NSString *firstWord = nil;
	BOOL foundWord = [[NSScanner scannerWithString:line] 
							scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] 
							intoString:&firstWord];
	
	if (!foundWord) {
		[self setError:error 
					 code:SIErrorInvalidStorySyntax 
			errorDomain:SIMON_ERROR_DOMAIN 
	 shortDescription:@"Story syntax error, step does not begin with a word" 
		 failureReason:@"Each line of a story must start with a valid keyword (Story, Given, Then, As or And) or a comment."];
		return SIKeywordUnknown;
	}
	
	SIKeyword keyword = [firstWord keywordFromString];
	if (keyword == SIKeywordUnknown) {
		[self setError:error 
					 code:SIErrorInvalidStorySyntax 
			errorDomain:SIMON_ERROR_DOMAIN 
	 shortDescription:[NSString stringWithFormat:@"Story syntax error, unknown keyword %@", firstWord] 
		 failureReason:[NSString stringWithFormat:@"Each line of a story must start with a valid keyword (Given, Then, As or And) or a comment. %@ is not a keyword.", firstWord]];
	}
	return keyword;
}


-(void) createNewStoryForSource:(SIStorySource *) source withTitle:(NSString *) title {

	// Create the new one and store it in the return array.
	DC_LOG(@"Creating new story");
	SIStory *story = [[[SIStory alloc] init] autorelease];
	[source.stories addObject:story];
	
	// Store the title.
	NSString *storyTitle = [[title substringFromIndex: 5] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if ([storyTitle hasPrefix:@":"]) {
		storyTitle = [[storyTitle substringFromIndex: 1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	}
	DC_LOG(@"Title: %@", storyTitle);
	story.title = storyTitle;
}


-(void) dealloc {
	DC_DEALLOC(trimChars);
	self.files = nil;
	[super dealloc];
}

@end
