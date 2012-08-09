//
//  SIStoryLogReporter.m
//  Simon
//
//  Created by Derek Clarkson on 6/28/11.
//  Copyright 2011. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>

#import "SIStoryLogger.h"
#import "SIStorySource.h"
#import "SIStory.h"
#import "SIStep.h"
#import "SIStepMapping.h"
#import "SIAppBackpack.h"
#import "NSString+Simon.h"

@interface SIStoryLogger() {
	@private

}

@end

@implementation SIStoryLogger

-(void) storyStarting:(NSNotification *) notification {
	[super storyStarting:notification];
	SIStorySource *source = [[notification userInfo] valueForKey:SI_NOTIFICATION_KEY_SOURCE];
	SIStory *story = [[notification userInfo] valueForKey:SI_NOTIFICATION_KEY_STORY];
	NSLog(@" ");
	NSLog(@"Starting story execution: %@", story.title);
	NSLog(@"Source: %@", source.source);
}

-(void) storyExecuted:(NSNotification *) notification {
	[super storyExecuted:notification];
	SIStory *story = [[notification userInfo] valueForKey:SI_NOTIFICATION_KEY_STORY];
	
	NSString *statusAsString = [NSString stringStatusWithStory:story];
	NSLog(@"Story executed: %@", story.title);
	
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

-(void) runFinished:(NSNotification *) notification {
	[super runFinished:notification];
	
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

	NSLog(@"Failures:");
	NSLog(@"====================================================");
	for (SIStory *story in [self storiesWithStatus:SIStoryStatusError]) {
		NSLog(@"Failed story: %@", story.title);
	}

	NSLog(@" ");
	NSLog(@"Final Report:");
	NSLog(@"====================================================");
	NSLog(@"Not run          : %u", [[self storiesWithStatus:SIStoryStatusNotRun] count]);
	NSLog(@"Successfully run : %u", [[self storiesWithStatus:SIStoryStatusSuccess] count]);
	NSLog(@"Not fully mapped : %u", [[self storiesWithStatus:SIStoryStatusNotMapped] count]);
	NSLog(@"Ignored          : %u", [[self storiesWithStatus:SIStoryStatusIgnored] count]);
	NSLog(@"Failures         : %u", [[self storiesWithStatus:SIStoryStatusError] count]);
	
}

@end
