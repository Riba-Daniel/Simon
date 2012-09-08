//
//  SIResultListenerTests.m
//  Simon
//
//  Created by Derek Clarkson on 9/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>

#import <Simon/SIResultListener.h>
#import <Simon/SIStory.h>
#import <Simon/SIConstants.h>
#import <OCMock/OCMock.h>
#import "GHTestCase+Utils.h"

@interface SIResultListenerTests : GHTestCase

@end

@implementation SIResultListenerTests

-(void) testStoresResultsAsExpectedForSuccess {

	// Setup mocked out notification.
	NSNotification *storyNotification = [self createMockedNotification:SI_STORY_EXECUTED_NOTIFICATION forStoryStatus:SIStoryStatusSuccess];
	id storyMock = [storyNotification.userInfo valueForKey:SI_NOTIFICATION_KEY_STORY];
	
	// Create listener
	SIResultListener *listener = [[[SIResultListener alloc] init] autorelease];
	
	// test.
	[listener storyExecuted:storyNotification];

	// Verify.
	NSArray *successfulStories = [listener storiesWithStatus:SIStoryStatusSuccess];
	GHAssertNotNil(successfulStories, nil);
	GHAssertEquals([successfulStories count], (NSUInteger) 1, nil);
	GHAssertEquals([successfulStories lastObject], storyMock, nil);
	
}

-(void) testReceivesNotifications {
	
	// Setup a mocked notification.
	NSNotification *storyNotification = [self createMockedNotification:SI_STORY_EXECUTED_NOTIFICATION forStoryStatus:SIStoryStatusSuccess];
	id storyMock = [storyNotification.userInfo valueForKey:SI_NOTIFICATION_KEY_STORY];
	
	// Create the listener.
	SIResultListener *listener = [[[SIResultListener alloc] init] autorelease];

	// Fire the notifications.
	[[NSNotificationCenter defaultCenter] postNotification:storyNotification];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	
	// Test the results.
	NSArray *successfulStories = [listener storiesWithStatus:SIStoryStatusSuccess];
	GHAssertEquals([successfulStories lastObject], storyMock, nil);
	
}

@end
