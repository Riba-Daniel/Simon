//
//  SIResultListener.m
//  
//
//  Created by Sensis on 8/08/12.
//
//

#import "SIResultListener.h"
#import "SIConstants.h"
#import <dUsefulStuff/DCCommon.h>
#import "SIStory.h"

@interface SIResultListener () {
@private
	NSMutableArray *storiesWithStatus[SIStoryStatusCount];
}

@end


@implementation SIResultListener

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
		for (int i = 0; i < SIStoryStatusCount; i++) {
			storiesWithStatus[i] = [[NSMutableArray alloc] init];
		}
	}
	return self;
}

-(void) storyStarting:(NSNotification *) notification {}

-(void) storyExecuted:(NSNotification *) notification {
	SIStory *story = [[notification userInfo] valueForKey:SI_NOTIFICATION_KEY_STORY];
	[storiesWithStatus[story.status] addObject:story];
}

-(void) runFinished:(NSNotification *) notification {}

-(NSArray *) storiesWithStatus:(SIStoryStatus) status {
	return storiesWithStatus[status];
}

-(void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	for (int i = 0; i < SIStoryStatusCount; i++) {
		DC_DEALLOC(storiesWithStatus[i]);
	}

	[super dealloc];
}

@end
