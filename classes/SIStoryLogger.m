//
//  SIStoryLogReporter.m
//  Simon
//
//  Created by Derek Clarkson on 6/28/11.
//  Copyright 2011. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>

#import <Simon/SIStoryLogger.h>
#import <Simon/SIStoryGroup.h>
#import <Simon/SIStory.h>
#import <Simon/SIStep.h>
#import <Simon/SIStepMapping.h>
#import <Simon/SIAppBackpack.h>
#import "NSString+Simon.h"

@interface SIStoryLogger()
-(void) log:(NSString *) message;
@end

@implementation SIStoryLogger

-(void) storyStarting:(NSNotification *) notification {
	[super storyStarting:notification];
	SIStoryGroup *storyGroup = [[notification userInfo] valueForKey:SI_NOTIFICATION_KEY_SOURCE];
	SIStory *story = [[notification userInfo] valueForKey:SI_NOTIFICATION_KEY_STORY];
	[self log:@" "];
	[self log:[NSString stringWithFormat:@"Starting story execution: %@", story.title]];
	[self log:[NSString stringWithFormat:@"Source: %@", storyGroup.source]];
}

-(void) storyExecuted:(NSNotification *) notification {
	[super storyExecuted:notification];

	SIStory *story = [[notification userInfo] valueForKey:SI_NOTIFICATION_KEY_STORY];
	[self log:[NSString stringWithFormat:@"Story executed: %@", story.title]];
	
	NSString *stepStatus;
	for (SIStep * step in story.steps) {
		if ([step isMapped]) {
			if (step.executed) {
				stepStatus = step.exception != nil ? @"Failed!" : @"Success";
			} else {
				stepStatus = @"Not executed";
			}
			
			[self log:[NSString stringWithFormat:@"   Step: \"%@\" (%@::%@] - %@", step.command,
					NSStringFromClass(step.stepMapping.targetClass),
					NSStringFromSelector(step.stepMapping.selector),
					stepStatus]];
		} else {
			[self log:[NSString stringWithFormat:@"   Step: %@, not mapped", step.command]];
		}
	}
	
	[self log:[NSString stringWithFormat:@"Result: %@", story.statusString]];
	
}

-(void) runFinished:(NSNotification *) notification {
	[super runFinished:notification];
	
	[self log:@"Simon's run report"];
	NSArray *mappings = [SIAppBackpack backpack].mappings;
	
	BOOL orphans = NO;
	if ([mappings count] > 0) {
		for (SIStepMapping * mapping in mappings) {
			if (!mapping.mapped) {
				if (!orphans) {
					orphans = YES;
					[self log:@" "];
					[self log:@"Unused mappings"];
					[self log:@"===================================================="];
				}
				[self log:[NSString stringWithFormat:@"\tMapping \"%@\" -> %@::%@", mapping.regex.pattern, NSStringFromClass(mapping.targetClass), NSStringFromSelector(mapping.selector)]];
			}
		}
	}

	[self log:@"Failures:"];
	[self log:@"===================================================="];
	for (SIStory *story in [self storiesWithStatus:SIStoryStatusError]) {
		[self log:[NSString stringWithFormat:@"Failed story: %@", story.title]];
	}

	[self log:@" "];
	[self log:@"Final Report:"];
	[self log:@"===================================================="];
	[self log:[NSString stringWithFormat:@"Not run          : %u", [[self storiesWithStatus:SIStoryStatusNotRun] count]]];
	[self log:[NSString stringWithFormat:@"Successfully run : %u", [[self storiesWithStatus:SIStoryStatusSuccess] count]]];
	[self log:[NSString stringWithFormat:@"Not fully mapped : %u", [[self storiesWithStatus:SIStoryStatusNotMapped] count]]];
	[self log:[NSString stringWithFormat:@"Ignored          : %u", [[self storiesWithStatus:SIStoryStatusIgnored] count]]];
	[self log:[NSString stringWithFormat:@"Failures         : %u", [[self storiesWithStatus:SIStoryStatusError] count]]];
	
}

-(void) log:(NSString *) message {
	@synchronized ([NSProcessInfo processInfo]) {
		CFShow(message);
		fflush(stderr);
	}
}

@end
