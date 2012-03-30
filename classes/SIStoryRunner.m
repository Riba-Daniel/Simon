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
#import "SIStoryInAppReporter.h"
#import <dUsefulStuff/DCDialogs.h>

@interface SIStoryRunner()
-(void) displayMessage:(NSString *) message;
@end

@implementation SIStoryRunner

@synthesize reader = reader_;
@synthesize runtime = runtime_;
@synthesize storySources = storySources_;
@synthesize stories = stories_;
@synthesize mappings = mappings_;

-(void) dealloc {
	DC_LOG(@"Deallocing");
	self.reader = nil;
	self.runtime = nil;
	self.storySources = nil;
	self.stories = nil;
	self.mappings = nil;
	DC_DEALLOC(ui);
	[super dealloc];
}

- (id)init
{
	self = [super init];
	if (self) {
		// Now setup the defaults.
		DC_LOG(@"Setting up reader, runtime ad reporters");
		self.reader = [[[SIStoryFileReader alloc] init] autorelease];
		self.runtime = [[[SIRuntime alloc] init] autorelease];
	}
	
	return self;
}

-(void) loadStories {
	// Read the stories.
	DC_LOG(@"Reading stories");
	NSError *error = nil;
	self.storySources = [self.reader readStorySources: &error];
	
	// If there was an error then return.
	if (self.storySources == nil) {
		DC_LOG(@"Error reading story files - exiting. Error %@", [error localizedFailureReason]);
		[self performSelectorOnMainThread:@selector(displayMessage:)
									  withObject:[error localizedFailureReason] waitUntilDone:NO];
		return;
	}
	
	// If no stories where read then generate an error and return.
	NSNumber *numberOfStories = [self.storySources valueForKeyPath:@"@count.stories"];
	if ([self.storySources count] == 0 || [numberOfStories integerValue] == 0) {
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
	
	// Read the runtime to local all mappings. 
	self.mappings = [self.runtime allMappingMethodsInRuntime];
	
   // Get a union of all the stories.
	self.stories = [self.storySources valueForKeyPath:@"@unionOfArrays.stories"];
	
	// Find the mapping for each story.
	DC_LOG(@"Mappin steps to story steps");
	for (SIStory *story in self.stories) {
		[story mapSteps:(NSArray *) self.mappings];
	}
	
}

-(void) runStories {
	
	DC_LOG(@"Running %lu stories", [self.stories count]);
   
	for (SIStory *story in self.stories) {
		if (![story invoke]) {
			if (story.status == SIStoryStatusNotMapped || story.status == SIStoryStatusError) {
				DC_LOG(@"Error executing y %@", [story.error localizedFailureReason]);
			}
		}
	}
	
	// Publish the results.
	DC_LOG(@"Logging report");
	SIStoryLogReporter *logger = [[SIStoryLogReporter alloc] init];
	[logger reportOnStorySources:self.storySources andMappings:self.mappings];
	[logger release];
}

-(void) displayUI {
	if (ui == nil) {
		ui = [[SIStoryInAppReporter alloc] init];
	}
	[ui reportOnStorySources:self.storySources andMappings:self.mappings];
}

-(void) displayMessage:(NSString *) message {
	[DCDialogs displayMessage:message];
}

@end
