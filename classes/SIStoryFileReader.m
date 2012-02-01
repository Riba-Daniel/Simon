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
-(void) mainInit;

@end

@implementation SIStoryFileReader

@synthesize files = files_;
@synthesize currentLineNumber = currentLineNumber_;
@synthesize currentSource = currentSource_;

-(void) dealloc {
	DC_DEALLOC(trimChars);
	self.files = nil;
	self.currentSource = nil;
	[super dealloc];
}

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
      
		NSString * file = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension] ofType:STORY_EXTENSION];
		SI_LOG(@"Found file %@", file);
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
		
		priorKeyword = SIKeywordStartOfFile;
		
		// Add the file as source.
		SIStorySource *source = [[[SIStorySource alloc] init] autorelease];
		source.source = file;
		[storySources addObject:source];
		
		self.currentSource = source;
		
		// Read the file.
		SI_LOG(@"Reading file: %@", file);
		NSString *contents = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:error];
		if (contents == nil) {
			SI_LOG(@"Failed to read file %@", file);
			return nil;
		}
		
		// Break it up and process the lines.
		NSUInteger lineNbr = 0;
		for (NSString * line in [contents componentsSeparatedByString:@"\n"]) {
			self.currentLineNumber = ++lineNbr;
			if (![self processLine: line error:error]) {
				return nil;
			}
		}
	}
	
	return storySources;
}

-(BOOL) processLine:(NSString *) line 
				  error:(NSError **) error {
	
	SI_LOG(@"Line: %@", line);
	
	// Trim whitespace and trailing punctuation.
	NSString *cleanLine = [line stringByTrimmingCharactersInSet:trimChars];
	
	// If there is nothing left or it starts with a comment char then ignore it.
	if ([cleanLine length] == 0 || [cleanLine hasPrefix:@"#"]) {
		return YES;
	}
	
	// Attempt to figure out what the keyword is.
	SIKeyword keyword = [self keywordFromLine:cleanLine error:error];
	if (keyword == SIKeywordUnknown) {
		SI_LOG(@"Detected unknown keyword in step: %@", cleanLine);
		NSString *msg = [self failureReasonWithContent:[NSString stringWithFormat:@"Story syntax error, unknown keyword on step \"%@\"", cleanLine]];
		[self setError:error code:SIErrorInvalidKeyword errorDomain:SIMON_ERROR_DOMAIN shortDescription:@"Story syntax error, unknown keyword" failureReason:msg];
		return NO;
	}
	
	// Validate the order of keywords.
	SI_LOG(@"Syntax check %@ -> %@", 
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
	SI_LOG(@"Adding step: %@", cleanLine);
	SIStory *story = [self.currentSource.stories lastObject];
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
	SI_LOG(@"Creating new story");
	SIStory *story = [[[SIStory alloc] init] autorelease];
	[self.currentSource.stories addObject:story];
	
	// Store the title.
	NSString *storyTitle = [[title substringFromIndex: 5] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if ([storyTitle hasPrefix:@":"]) {
		storyTitle = [[storyTitle substringFromIndex: 1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	}
	SI_LOG(@"Title: %@", storyTitle);
	story.title = storyTitle;
}

-(NSString *)failureReasonWithContent:(NSString *) content {
	return [NSString stringWithFormat:@"%@[line %i]: %@", [self.currentSource.source lastPathComponent], self.currentLineNumber, content];
}


@end
