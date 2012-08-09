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
#import "GHTestCase+GHTestCase_TestUtils.h"

@interface SIResultListenerTests : GHTestCase

@end

@implementation SIResultListenerTests

-(void) testStoresResultsAsExpectedForSuccess {

	NSNotification *storyNotification = [self createMockedNotification:SI_STORY_EXECUTED_NOTIFICATION forStoryStatus:SIStoryStatusSuccess];
	id storyMock = [storyNotification.userInfo valueForKey:SI_NOTIFICATION_KEY_STORY];
	SIResultListener *listener = [[[SIResultListener alloc] init] autorelease];
	
	[listener storyExecuted:storyNotification];

	NSArray *successfulStories = [listener storiesWithStatus:SIStoryStatusSuccess];
	GHAssertNotNil(successfulStories, nil);
	GHAssertEquals([successfulStories count], (NSUInteger) 1, nil);
	GHAssertEquals([successfulStories lastObject], storyMock, nil);
	
}

-(void) testReceivesNotifications {
	
	NSNotification *storyNotification = [self createMockedNotification:SI_STORY_EXECUTED_NOTIFICATION forStoryStatus:SIStoryStatusSuccess];
	id storyMock = [storyNotification.userInfo valueForKey:SI_NOTIFICATION_KEY_STORY];
	SIResultListener *listener = [[[SIResultListener alloc] init] autorelease];

	[[NSNotificationCenter defaultCenter] postNotification:storyNotification];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	
	NSArray *successfulStories = [listener storiesWithStatus:SIStoryStatusSuccess];
	GHAssertEquals([successfulStories lastObject], storyMock, nil);
	
}

@end
