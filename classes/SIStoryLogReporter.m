//
//  SIStoryLogReporter.m
//  Simon
//
//  Created by Derek Clarkson on 6/28/11.
//  Copyright 2011. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>

#import "SIStoryLogReporter.h"
#import "SIStory.h"
#import "SIStep.h"
#import "SIStepMapping.h"
#import "NSString+Simon.h"

@interface SIStoryLogReporter()
-(void) reportStory:(SIStory *) story
			 successes:(NSMutableArray *) successes
			 notMapped:(NSMutableArray *) notMapped
			  failures:(NSMutableArray *) failures
				ignored:(NSMutableArray *) ignored
				 notRun:(NSMutableArray *) notRun;
-(void) reportUnusedMappings:(NSArray *) mappings;
@end

@implementation SIStoryLogReporter

-(void) reportOnStorySources:(NSArray *) sources andMappings:(NSArray *) mappings {
	
	NSLog(@"Simon's run report");
	NSLog(@"====================================================");
	
	// Count result types.
	NSMutableArray *successes = [NSMutableArray array];
	NSMutableArray *notMapped = [NSMutableArray array];
	NSMutableArray *failures = [NSMutableArray array];
	NSMutableArray *ignored = [NSMutableArray array];
	NSMutableArray *notRun = [NSMutableArray array];
	
	NSArray *stories = [sources valueForKeyPath:@"@unionOfArrays.stories"];
	
	for (SIStory * story in stories) {
		[self reportStory:story successes:successes notMapped:notMapped failures:failures ignored:ignored notRun:notRun];
	}
	
	NSLog(@" ");
	NSLog(@"Final Report:");
	NSLog(@"Total stories    : %u", [stories count]);
	NSLog(@"Not run          : %u", [notRun count]);
	NSLog(@"Not fully mapped : %u", [notMapped count]);
	NSLog(@"Successfully run : %u", [successes count]);
	NSLog(@"Ignored          : %u", [ignored count]);
	NSLog(@"Failures         : %u", [failures count]);
	
	for (SIStory *story in failures) {
		NSLog(@"Failed story: %@", story.title);
	}
	
	[self reportUnusedMappings:mappings];
	
}

-(void) reportStory:(SIStory *) story
			 successes:(NSMutableArray *) successes
			 notMapped:(NSMutableArray *) notMapped
			  failures:(NSMutableArray *) failures
				ignored:(NSMutableArray *) ignored
				 notRun:(NSMutableArray *) notRun {
	
	NSString *status = [NSString stringStatusWithStory:story];
	switch (story.status) {
		case SIStoryStatusSuccess:
			[successes addObject:story];
			break;
		case SIStoryStatusNotMapped:
			[notMapped addObject:story];
			break;
		case SIStoryStatusError:
			[failures addObject:story];
			break;
		case SIStoryStatusIgnored:
			[ignored addObject:story];
			break;
		default:
			[notRun addObject:story];
			break;
	}

	NSLog(@" ");
	NSLog(@"Story: %@", story.title);
	
	for (SIStep * step in story.steps) {
		if ([step isMapped]) {
			NSString *status;
			if (step.stepMapping.executed) {
				status = step.stepMapping.exception != nil ? @"Failed!" : @"Success";
			} else {
				status = @"Not executed";
			}
			
			NSLog(@"   Step: \"%@\" (%@::%@) - %@", step.command, 
					NSStringFromClass(step.stepMapping.targetClass),
					NSStringFromSelector(step.stepMapping.selector),
					status);
		} else {
			NSLog(@"   Step: %@, NOT MAPPED", step.command);
		}
	}

	NSLog(@"Result: %@", status);

}

-(void) reportUnusedMappings:(NSArray *) mappings {

	NSLog(@" ");
	if ([mappings count] > 0) {
		NSLog(@"Step mappings not mapped to stories");
		for (SIStepMapping * mapping in mappings) {
			if (mapping.selector == nil && !mapping.executed) {
				NSLog(@"\tMapping \"%@\" -> %@::%@", mapping.regex.pattern, NSStringFromClass(mapping.targetClass), NSStringFromSelector(mapping.selector));
			}
		}
	} else {
		NSLog(@"All step mappings where mapped to stories.");
	}
}


@end
