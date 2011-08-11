//
//  StoryRunner.m
//  Simon
//
//  Created by Derek Clarkson on 6/17/11.
//  Copyright 2011 Sensis. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import <dUsefulStuff/NSObject+dUsefulStuff.h>
#import "SIStoryRunner.h"
#import "SIStory.h"
#import "SIStepMapping.h"
#import "NSObject+Utils.h"
#import "SIStoryLogReporter.h"

@interface SIStoryRunner()
@end

@implementation SIStoryRunner

@synthesize reader;
@synthesize runtime;
@synthesize reporter;

- (id)init
{
	self = [super init];
	if (self) {
		// Now setup the defaults.
		reader = [[SIStoryFileReader alloc] init];
		runtime = [[SIRuntime alloc] init];
		reporter = [[SIStoryLogReporter alloc] init];
	}
	
	return self;
}

-(BOOL) runStories:(NSError **) error {
	
	// Read the runtime to local all mappings. 
	NSArray * mappings = [runtime allMappingMethodsInRuntime];
	
	// Read the stories.
	DC_LOG(@"Reading stories");
	NSArray *stories = [reader readStories: error];
	
	// If there was an error then return.
	if (stories == nil) {
		DC_LOG(@"Error reading story files. Exiting");
		return NO;
	}
	
	// If no stories where read then generate an error and return.
	if ([stories count] == 0) {
		*error = [self errorForCode:SIErrorNoStoriesFound 
							 errorDomain:SIMON_ERROR_DOMAIN 
					  shortDescription:@"No stories read" 
						  failureReason:@"No stories where read from the files."];
		DC_LOG(@"No stories found. Exiting");
		return NO;
	}
	
	// Find the mapping for each story.
	DC_LOG(@"Mappin steps to story steps");
	for (SIStory *story in stories) {
		[story mapSteps:(NSArray *) mappings];
	}
	
	// Now execute the stories.
	DC_LOG(@"Running %lu stories", [stories count]);
	BOOL success = YES;
	for (SIStory *story in stories) {
		if (![story invoke]) {
			if (story.status == SIStoryStatusNotMapped || story.status == SIStoryStatusError) {
				*error = [self errorForCode:SIErrorStoryFailures 
									 errorDomain:SIMON_ERROR_DOMAIN 
							  shortDescription:@"One or more stories failed." 
								  failureReason:@"One or more stories either failed or was not mapped fully."];
				success = NO;
			}
		}
	}
	
	// Publish the results.
	[reporter reportOnStories:stories andMappings:mappings];
	
	DC_LOG(@"Done. All stories succeeded ? %@", DC_PRETTY_BOOL(success));
	return success;
}


-(void) dealloc {
	self.reader = nil;
	DC_DEALLOC(runtime);
	self.reporter = nil;
	[super dealloc];
}

@end
