//
//  StoryRunner.m
//  Simon
//
//  Created by Derek Clarkson on 6/17/11.
//  Copyright 2011. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import <dUsefulStuff/NSObject+dUsefulStuff.h>
#import <Simon/SIAppBackpack.h>
#import <Simon/SIStoryRunner.h>
#import <Simon/SIStory.h>
#import <Simon/SIStepMapping.h>
#import "NSString+Simon.h"
#import <UIKit/UIKit.h>

#define STORYBLOCK_ARG_DEFS SIStorySource *source, NSInteger sourceIdx, BOOL *sourceStop, SIStory *story, NSInteger storyIdx, BOOL *storyStop
typedef void (^StoryBlock)(STORYBLOCK_ARG_DEFS);

@interface SIStoryRunner(_private)
-(void) executeOnSources:(NSArray *) sources block:(StoryBlock) block;
-(void) runAllSelected;
-(void) runCurrentStory;
@end

@implementation SIStoryRunner

@synthesize storySources = _storySources;

-(void) run {

	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:SI_RUN_STARTING_NOTIFICATION object:nil]];

	// First reset all the stories we are going to run.
	DC_LOG(@"Starting run");
	if (self.storySources.currentIndexPath == nil) {
		[self runAllSelected];
	} else {
		[self runCurrentStory];
	}
	
	// Let the backpack know we have finished running stories.
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:SI_RUN_FINISHED_NOTIFICATION object:nil]];
}

-(void) runAllSelected {
	DC_LOG(@"Running all selected stories");
	DC_LOG(@"Resetting stories");
	[self executeOnSources:self.storySources.selectedSources block:^(STORYBLOCK_ARG_DEFS){
		[story reset];
	}];
   
	// Now execute them.
	DC_LOG(@"Executing");
	[self executeOnSources:self.storySources.selectedSources block:^(STORYBLOCK_ARG_DEFS){
		[story invokeWithSource:source];
	}];
}

-(void) runCurrentStory {
	NSIndexPath *indexPath = self.storySources.currentIndexPath;
	DC_LOG(@"Running current story at indexPath: %@", indexPath);
	DC_LOG(@"Resetting story");
	[self executeOnSources:self.storySources.selectedSources block:^(STORYBLOCK_ARG_DEFS){
		if (indexPath.section == sourceIdx && indexPath.row == storyIdx) {
			[story reset];
			*storyStop = YES;
			*sourceStop = YES;
		}
	}];
   
	// Now execute them.
	DC_LOG(@"Executing");
	[self executeOnSources:self.storySources.selectedSources block:^(STORYBLOCK_ARG_DEFS){
		if (indexPath.section == sourceIdx && indexPath.row == storyIdx) {
			[story invokeWithSource:source];
			*storyStop = YES;
			*sourceStop = YES;
		}
	}];
	
}

-(void) executeOnSources:(NSArray *) sources block:(StoryBlock) block {
	[sources enumerateObjectsUsingBlock:^(id sourceObj, NSUInteger sourceIdx, BOOL *sourceStop) {
		SIStorySource *source = (SIStorySource *) sourceObj;
		[source.stories enumerateObjectsUsingBlock:^(id storyObj, NSUInteger storyIdx, BOOL *storyStop) {
			SIStory *story = (SIStory *) storyObj;
			block(source, (NSInteger)sourceIdx, sourceStop, story, (NSInteger)storyIdx, storyStop);
		}];
	}];
}

@end
