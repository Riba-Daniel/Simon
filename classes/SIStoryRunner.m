//
//  StoryRunner.m
//  Simon
//
//  Created by Derek Clarkson on 6/17/11.
//  Copyright 2011. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import <dUsefulStuff/NSObject+dUsefulStuff.h>
#import "SIStoryRunner.h"
#import "SIStory.h"
#import "SIStepMapping.h"
#import "NSString+Simon.h"
#import "SIStoryLogReporter.h"
#import <dUsefulStuff/DCDialogs.h>
#import "NSArray+Simon.h"

@interface SIStoryRunner(_private)
-(void) displayMessage:(NSString *) message;
-(void) displayUI;
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

-(void) loadStories {
	// Read the stories.
	DC_LOG(@"Reading stories");
	NSError *error = nil;
	NSArray *storySources = [self.reader readStorySources: &error];
	
	// If there was an error then return.
	if (storySources == nil) {
		DC_LOG(@"Error reading story files - exiting. Error %@", [error localizedFailureReason]);
		[self performSelectorOnMainThread:@selector(displayMessage:)
									  withObject:[error localizedFailureReason] waitUntilDone:NO];
		return;
	}
	
	// If no stories where read then generate an error and return.
	NSUInteger numberOfStories = [(NSArray *)[storySources valueForKeyPath:@"@unionOfArrays.stories"] count];
	if ([storySources count] == 0 || numberOfStories == 0) {
		[self setError:&error 
					 code:SIErrorNoStoriesFound 
			errorDomain:SIMON_ERROR_DOMAIN 
	 shortDescription:@"No stories read" 
		 failureReason:@"No stories where read from the files."];
		DC_LOG(@"Error reading story files - exiting. Error %@", [error localizedFailureReason]);
		[self performSelectorOnMainThread:@selector(displayMessage:)
									  withObject:[error localizedFailureReason] waitUntilDone:NO];
		return;
	}
	
	// Read the runtime to locate all mappings. 
	self.mappings = [self.runtime allMappingMethodsInRuntime];
	
   // Get a union of all the stories.
	NSArray *stories = [storySources valueForKeyPath:@"@unionOfArrays.stories"];
	
	// Find the mapping for each story.
	DC_LOG(@"Mappin steps to story steps");
	for (SIStory *story in stories) {
		[story mapSteps:(NSArray *) self.mappings];
	}
	
}

-(void) run {
	
	NSArray *filteredSources = [SIAppBackpack backpack].state.filteredSources;
	NSArray *sources = filteredSources == nil ? self.reader.storySources : filteredSources;
	
	// First reset all the stories we are going to run.
	DC_LOG(@"Starting run");
	NSArray *stories = [sources storiesFromSources];
	for (SIStory *story in stories) {
		[story reset];
	}
   
	// Now execute them.
	for (SIStory *story in stories) {
		if (![story invoke]) {
			if (story.status == SIStoryStatusNotMapped || story.status == SIStoryStatusError) {
				DC_LOG(@"Error executing y %@", [story.error localizedFailureReason]);
			}
		}
	}
	
	// Publish the results.
	DC_LOG(@"Logging report");
	SIStoryLogReporter *logger = [[SIStoryLogReporter alloc] init];
	[logger reportOnSources:sources andMappings:self.mappings];
	[logger release];
	
	// Let the backpack know we have finished running stories.
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:SI_RUN_FINISHED_NOTIFICATION object:nil]];
}

-(void) displayMessage:(NSString *) message {
	[DCDialogs displayMessage:message];
}

@end
