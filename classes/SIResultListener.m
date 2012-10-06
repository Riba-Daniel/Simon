//
//  SIResultListener.m
//  
//
//  Created by on 8/08/12.
//
//

#import <Simon/SIResultListener.h>
#import <Simon/SIConstants.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIStory.h>

@interface SIResultListener () {
@private
	// An arrar of lists which store the stories for a particular status.
	NSMutableArray *resultsByStatus[SIStoryStatusCount];
}

@end


@implementation SIResultListener

-(void) dealloc {
	DC_LOG(@"Deallocing");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	for (int i = 0; i < SIStoryStatusCount; i++) {
		DC_DEALLOC(resultsByStatus[i]);
	}
	
	[super dealloc];
}

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
															  selector:@selector(runStarting:)
																	name:SI_RUN_STARTING_NOTIFICATION
																 object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(runFinished:)
																	name:SI_RUN_FINISHED_NOTIFICATION
																 object:nil];
		for (int i = 0; i < SIStoryStatusCount; i++) {
			resultsByStatus[i] = [[NSMutableArray alloc] init];
		}
	}
	return self;
}

-(void) storyStarting:(NSNotification *) notification {}

-(void) storyExecuted:(NSNotification *) notification {
	SIStory *story = [[notification userInfo] valueForKey:SI_NOTIFICATION_KEY_STORY];
	[resultsByStatus[story.status] addObject:story];
}

-(void) runStarting:(NSNotification *)notification {
	for (int i = 0; i < SIStoryStatusCount; i++) {
		DC_DEALLOC(resultsByStatus[i]);
		resultsByStatus[i] = [[NSMutableArray alloc] init];
	}
}

-(void) runFinished:(NSNotification *) notification {}

-(NSArray *) storiesWithStatus:(SIStoryStatus) status {
	return resultsByStatus[status];
}

@end
