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

@interface SIStoryRunner()
@end

@implementation SIStoryRunner

@synthesize reader = reader_;
@synthesize runtime = runtime_;
@synthesize reporters = reporters_;
@synthesize stories = stories_;

- (id)init
{
	self = [super init];
	if (self) {
		// Now setup the defaults.
		DC_LOG(@"Setting up reader, runtime ad reporters");
		self.reader = [[[SIStoryFileReader alloc] init] autorelease];
		self.runtime = [[[SIRuntime alloc] init] autorelease];
		self.reporters = [NSArray arrayWithObjects:
								[[[SIStoryLogReporter alloc] init] autorelease], 
								[[[SIStoryInAppReporter alloc] init] autorelease],
								nil];
	}
	
	return self;
}

-(BOOL) runStories:(NSError **) error {
	
	// Read the runtime to local all mappings. 
	NSArray * mappings = [self.runtime allMappingMethodsInRuntime];
	
	// Read the stories.
	DC_LOG(@"Reading stories");
	self.stories = [self.reader readStories: error];
	
	// If there was an error then return.
	if (self.stories == nil) {
		DC_LOG(@"Error reading story files. Exiting");
		return NO;
	}
	
	// If no stories where read then generate an error and return.
	if ([self.stories count] == 0) {
		[self setError:error 
					 code:SIErrorNoStoriesFound 
			errorDomain:SIMON_ERROR_DOMAIN 
	 shortDescription:@"No stories read" 
		 failureReason:@"No stories where read from the files."];
		DC_LOG(@"No stories found. Exiting");
		return NO;
	}
	
	// Find the mapping for each story.
	DC_LOG(@"Mappin steps to story steps");
	for (SIStory *story in self.stories) {
		[story mapSteps:(NSArray *) mappings];
	}
	
	// Now execute the stories.
	DC_LOG(@"Running %lu stories", [self.stories count]);
	BOOL success = YES;
	for (SIStory *story in self.stories) {
		if (![story invoke]) {
			if (story.status == SIStoryStatusNotMapped || story.status == SIStoryStatusError) {
				[self setError:error 
							 code:SIErrorStoryFailures 
					errorDomain:SIMON_ERROR_DOMAIN 
			 shortDescription:@"One or more stories failed." 
				 failureReason:@"One or more stories either failed or was not mapped fully."];
				success = NO;
			}
		}
	}
	
	// Publish the results.
	DC_LOG(@"Calling reporters");
	for (NSObject<SIStoryReporter> *reporter in self.reporters) {
		[reporter reportOnStories:self.stories andMappings:mappings];
	}
	
	DC_LOG(@"Done. All stories succeeded ? %@", DC_PRETTY_BOOL(success));
	return success;
}


-(void) dealloc {
	DC_LOG(@"Deallocing");
	self.reader = nil;
	self.runtime = nil;
	self.reporters = nil;
	self.stories = nil;
	[super dealloc];
}

@end
