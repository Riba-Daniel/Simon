//
//  FileSystemStoryReader.m
//  Simon
//
//  Created by Derek Clarkson on 5/30/11.
//  Copyright 2011. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import <dUsefulStuff/NSObject+dUsefulStuff.h>

#import <Simon/SIStoryAnalyser.h>
#import <Simon/SIConstants.h>
#import <Simon/NSString+Simon.h>
#import <Simon/SIStorySyntaxParser.h>

@interface SIStoryAnalyser() {
@private
	NSMutableCharacterSet *_trimChars;
	SIStorySyntaxParser *_parser;
	id<SIStoryTextSource> _storyTextSource;
}

@property (nonatomic, retain) SIStorySyntaxParser *parser;
@property (nonatomic, retain) SIStoryGroup *currentStoryGroup;
@property (nonatomic, retain) SIStory *currentStory;

-(void) createNewStoryWithTitle:(NSString *) title;
@end

@implementation SIStoryAnalyser

#pragma mark - Properties

@synthesize storyGroupManager = _storyGroupManager;
@synthesize parser = _parser;
@synthesize currentStoryGroup = _currentStoryGroup;
@synthesize currentStory = _currentStory;

#pragma mark - Lifecycle

-(void) dealloc {
	DC_LOG(@"Deallocing");
	self.parser = nil;
	self.currentStoryGroup = nil;
	self.currentStory = nil;
	DC_DEALLOC(_storyGroupManager);
	DC_DEALLOC(_trimChars);
	DC_DEALLOC(_storyTextSource);
	[super dealloc];
}

-(id) initWithStoryTextSource:(id<SIStoryTextSource>) storyTextSource {
	self = [super init];
	if (self) {
		_storyTextSource = [storyTextSource retain];
		_storyTextSource.delegate = self;
		_storyGroupManager = [[SIStoryGroupManager alloc] init];
		_trimChars = [[NSMutableCharacterSet whitespaceCharacterSet] retain];
		[_trimChars formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@".,;:!?"]];
	}
	return self;
}

#pragma mark - Tasks

-(BOOL) startWithError:(NSError **) error {
	return [_storyTextSource startWithError:error];
}

#pragma mark - Delegate methods

-(BOOL) storyTextSource:(id<SIStoryTextSource>) textSource willReadFromSource:(NSString *) source error:(NSError **) error {
	// Add the file as source.
	DC_LOG(@"Adding new source: %@", source);
	SIStoryGroup *newStoryGroup = [[[SIStoryGroup alloc] init] autorelease];
	newStoryGroup.source = source;
	[_storyGroupManager addStoryGroup:newStoryGroup];
	self.currentStoryGroup = newStoryGroup;
	
	// Prep a new parser.
	self.parser = [[[SIStorySyntaxParser alloc] init] autorelease];
	return YES;
}

-(BOOL) storyTextSource:(id<SIStoryTextSource>) textSource readLine:(NSString *) line error:(NSError **) error {
	DC_LOG(@"Line: %@", line);
	
	// Trim whitespace and trailing punctuation and
	// if there is nothing left or it starts with a comment char then ignore it.
	NSString *cleanLine = [line stringByTrimmingCharactersInSet:_trimChars];
	if ([cleanLine length] == 0 || [cleanLine hasPrefix:@"#"]) {
		return YES;
	}
	
	// Now parse the line.
	SIKeyword keyword = [_parser checkLine:cleanLine error:error];
	if (keyword == SIKeywordUnknown) {
		return NO;
	}

	// Create a new story if its the story keyword and return without add a step.
	 if (keyword == SIKeywordStory) {
		 [self createNewStoryWithTitle:cleanLine];
	 return YES;
	 }
	// Now add the step to the current story.
	DC_LOG(@"Adding step: %@", cleanLine);
	//SIStory *story = [source.stories lastObject];
	//[story createStepWithKeyword:keyword command:cleanLine];
	
	return YES;
}

-(BOOL) storyTextSource:(id<SIStoryTextSource>) textSource didReadFromSource:(NSString *) source error:(NSError **) error {
	return YES;
}

#pragma mark - Internal

-(void) createNewStoryWithTitle:(NSString *) title {
	
	// Create the new one and store it in the return array.
	DC_LOG(@"Creating new story");
	SIStory *story = [[SIStory alloc] init];
	[self.currentStoryGroup addStory:story];
	self.currentStory = story;
	
	// Store the title.
	NSString *storyTitle = [[title stringByReplacingOccurrencesOfString:@"story:?"
																				withString:@""
																					options:NSCaseInsensitiveSearch | NSRegularExpressionSearch
																					  range:NSMakeRange(0, 8)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	DC_LOG(@"Title: %@", storyTitle);
	story.title = storyTitle;
	[story release];
}


@end
