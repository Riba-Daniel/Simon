//
//  SIStoryLogReporter.m
//  Simon
//
//  Created by Derek Clarkson on 6/28/11.
//  Copyright 2011. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>

#import "SIStoryLogReporter.h"
#import "SIStorySource.h"
#import "SIStory.h"
#import "SIStep.h"
#import "SIStepMapping.h"
#import "NSString+Simon.h"
#import "NSArray+Simon.h"
#import "SIAppBackpack.h"

@interface SIStoryLogReporter() {
	@private
	NSUInteger statusCounts[5];

}
-(void) storyStarting:(NSNotification *) notification;
-(void) storyExecuted:(NSNotification *) notification;
-(void) runFinished:(NSNotification *) notification;

@end

@implementation SIStoryLogReporter

-(id) init {
	self = [super init];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(storyStarting:)
																	name:SI_STORY_STARTING_EXECUTION_NOTIFICATION
																 object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(storyExecuted:)
																	name:SI_STORY_EXECUTED_NOTIFICATION
																 object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(runFinished:)
																	name:SI_RUN_FINISHED_NOTIFICATION
																 object:nil];
	}
	return self;
}
-(void) storyStarting:(NSNotification *) notification {
	SIStorySource *source = [[notification userInfo] valueForKey:SI_NOTIFICATION_KEY_SOURCE];
	SIStory *story = [[notification userInfo] valueForKey:SI_NOTIFICATION_KEY_STORY];
	NSLog(@" ");
	NSLog(@"Starting story execution: %@", story.title);
	NSLog(@"Source: %@", source.source);
}

-(void) storyExecuted:(NSNotification *) notification {
	
	SIStory *story = [[notification userInfo] valueForKey:SI_NOTIFICATION_KEY_STORY];

	NSString *statusAsString = [NSString stringStatusWithStory:story];
	NSLog(@"Story executed: %@", story.title);
	
	// Count the state
	statusCounts[story.status]++;
	
	NSString *stepStatus;
	for (SIStep * step in story.steps) {
		if ([step isMapped]) {
			if (step.executed) {
				stepStatus = step.exception != nil ? @"Failed!" : @"Success";
			} else {
				stepStatus = @"Not executed";
			}
			
			NSLog(@"   Step: \"%@\" (%@::%@) - %@", step.command,
					NSStringFromClass(step.stepMapping.targetClass),
					NSStringFromSelector(step.stepMapping.selector),
					stepStatus);
		} else {
			NSLog(@"   Step: %@, not mapped", step.command);
		}
	}
	
	NSLog(@"Result: %@", statusAsString);

}

-(void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

-(void) runFinished:(NSNotification *) notification {

	NSLog(@"Simon's run report");
	NSArray *mappings = [SIAppBackpack backpack].mappings;

	BOOL orphans = NO;
	if ([mappings count] > 0) {
		for (SIStepMapping * mapping in mappings) {
			if (!mapping.mapped) {
				if (!orphans) {
					orphans = YES;
					NSLog(@" ");
					NSLog(@"Unused mappings");
					NSLog(@"====================================================");
				}
				NSLog(@"\tMapping \"%@\" -> %@::%@", mapping.regex.pattern, NSStringFromClass(mapping.targetClass), NSStringFromSelector(mapping.selector));
			}
		}
	}

	NSLog(@" ");
	NSLog(@"Final Report:");
	NSLog(@"====================================================");
	NSLog(@"Not run          : %u", statusCounts[SIStoryStatusNotRun]);
	NSLog(@"Successfully run : %u", statusCounts[SIStoryStatusSuccess]);
	NSLog(@"Not fully mapped : %u", statusCounts[SIStoryStatusNotMapped]);
	NSLog(@"Ignored          : %u", statusCounts[SIStoryStatusIgnored]);
	NSLog(@"Failures         : %u", statusCounts[SIStoryStatusError]);

	/*
	for (SIStory *story in failures) {
		NSLog(@"Failed story: %@", story.title);
	}
	 */

}


@end
