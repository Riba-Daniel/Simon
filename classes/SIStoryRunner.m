//
//  StoryRunner.m
//  Simon
//
//  Created by Derek Clarkson on 6/17/11.
//  Copyright 2011. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import <dUsefulStuff/NSObject+dUsefulStuff.h>
#import "SIAppBackpack.h"
#import "SIStoryRunner.h"
#import "SIStory.h"
#import "SIStepMapping.h"
#import "NSString+Simon.h"
#import "NSArray+Simon.h"

typedef void (^StoryBlock)(SIStorySource *, SIStory *);

@interface SIStoryRunner(_private)
-(void) executeOnSources:(NSArray *) sources block:(StoryBlock) block;
@end

@implementation SIStoryRunner

@synthesize reader = reader_;
@synthesize runtime = runtime_;
@synthesize mappings = mappings_;

-(void) dealloc {
	DC_LOG(@"Deallocing");
	self.reader = nil;
	self.runtime = nil;
	self.mappings = nil;
	[super dealloc];
}

- (id)init
{
	self = [super init];
	if (self) {
		// Now setup the defaults.
		DC_LOG(@"Setting up reader and runtime");
		SIStoryFileReader *reader = [[SIStoryFileReader alloc] init];
		self.reader = reader;
		[reader release];
		SIRuntime *runtime = [[SIRuntime alloc] init];
		self.runtime = runtime;
		[runtime release];
	}
	
	return self;
}

-(BOOL) loadStories:(NSError **) error {

	// Read the stories.
	DC_LOG(@"Reading stories");
	NSArray *storySources = [self.reader readStorySources: error];
	
	// If there was an error then return.
	if (storySources == nil) {
		DC_LOG(@"Error reading story files: %@", [*error localizedFailureReason]);
		return NO;
	}
	
   // Get a union of all the stories.
	NSArray *stories = [storySources storiesFromSources];

	// If no stories where read then generate an error and return.
	NSUInteger numberOfStories = [stories count];
	if ([storySources count] == 0 || numberOfStories == 0) {
		[self setError:error
					 code:SIErrorNoStoriesFound
			errorDomain:SIMON_ERROR_DOMAIN
	 shortDescription:@"No stories read"
		 failureReason:@"No stories where read from the files."];
		DC_LOG(@"Error reading story files: %@", [*error localizedFailureReason]);
		return NO;
	}
	
	// Read the runtime to locate all mappings.
	self.mappings = [self.runtime allMappingMethodsInRuntime];
	
	// Find the mapping for each story.
	DC_LOG(@"Mappin steps to story steps");
	for (SIStory *story in stories) {
		[story mapSteps:(NSArray *) self.mappings];
	}
	
	return YES;
	
}

-(void) run {

	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:SI_RUN_STARTING_NOTIFICATION object:nil]];

	NSArray *filteredSources = [SIAppBackpack backpack].state.filteredSources;
	NSArray *sources = filteredSources == nil ? self.reader.storySources : filteredSources;

	// First reset all the stories we are going to run.
	DC_LOG(@"Starting run");
	DC_LOG(@"Resetting stories");
	[self executeOnSources:sources block:^(SIStorySource *source, SIStory *story){
		[story reset];
	}];
   
	// Now execute them.
	DC_LOG(@"Executing");
	[self executeOnSources:sources block:^(SIStorySource *source, SIStory *story){
		[story invokeWithSource:source];
	}];
	
	// Let the backpack know we have finished running stories.
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:SI_RUN_FINISHED_NOTIFICATION object:nil]];
}

-(void) executeOnSources:(NSArray *) sources block:(StoryBlock) block {
	for (SIStorySource *source in sources) {
		for (SIStory *story in source.stories) {
			block(source, story);
		}
	}
}

@end
