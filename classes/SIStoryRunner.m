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

typedef void (^StoryBlock)(SIStorySource *, SIStory *);

@interface SIStoryRunner(_private)
-(void) executeOnSources:(NSArray *) sources block:(StoryBlock) block;
@end

@implementation SIStoryRunner

@synthesize storySources = _storySources;

-(void) run {

	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:SI_RUN_STARTING_NOTIFICATION object:nil]];

	// First reset all the stories we are going to run.
	DC_LOG(@"Starting run");
	DC_LOG(@"Resetting stories");
	[self executeOnSources:_storySources.selectedSources block:^(SIStorySource *source, SIStory *story){
		[story reset];
	}];
   
	// Now execute them.
	DC_LOG(@"Executing");
	[self executeOnSources:_storySources.selectedSources block:^(SIStorySource *source, SIStory *story){
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
