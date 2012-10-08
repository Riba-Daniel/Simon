//
//  PIReporter.m
//  Simon
//
//  Created by Derek Clarkson on 8/10/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "PIReporter.h"
#import <Simon/SIStory.h>
#import <Simon/SIFinalReport.h>

@interface PIReporter ()
-(void) storyFinishedReceivedWithNotification:(NSNotification *) notification;
-(void) runFinishedReceivedWithNotification:(NSNotification *) notification;
@end

@implementation PIReporter

-(void) dealloc {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self];
	[super dealloc];
}

-(id) init {
	self = [super init];
	if (self) {
		// Register for notifications
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center addObserver:self selector:@selector(storyFinishedReceivedWithNotification:) name:PI_STORY_FINISHED_NOTIFICATION object:nil];
		[center addObserver:self selector:@selector(runFinishedReceivedWithNotification:) name:PI_RUN_FINISHED_NOTIFICATION object:nil];
	}
	return self;
}

-(void) storyFinishedReceivedWithNotification:(NSNotification *) notification {
	NSDictionary *userInfo = notification.userInfo;
	SIStory *story = [userInfo valueForKey:PI_USERINFO_KEY_STORY];
	[self storyFinished:story];
}

-(void) runFinishedReceivedWithNotification:(NSNotification *) notification {
	NSDictionary *userInfo = notification.userInfo;
	SIFinalReport *report = [userInfo valueForKey:PI_USERINFO_KEY_RESULTS];
	[self runFinished:report];
}

#pragma mark - Methods to be overridden.

-(void) storyFinished:(SIStory *) story {}

-(void) runFinished:(SIFinalReport *) report {}

@end
