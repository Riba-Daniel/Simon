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

@interface SIResultListenerTests : GHTestCase

@end

@implementation SIResultListenerTests

-(void) testStoresResultsAsExpectedForSuccess {

	SIResultListener *listener = [[[SIResultListener alloc] init] autorelease];
	
	id storyMock1 = [OCMockObject mockForClass:[SIStory class]];
	SIStoryStatus status = SIStoryStatusSuccess;
	[[[storyMock1 expect] andReturnValue:OCMOCK_VALUE(status)] status];
	NSDictionary *userData = [NSDictionary dictionaryWithObject:storyMock1 forKey:SI_NOTIFICATION_KEY_STORY];
	NSNotification *story1Notification = [NSNotification notificationWithName:SI_STORY_EXECUTED_NOTIFICATION object:self userInfo:userData];
	
	[listener storyExecuted:story1Notification];
	
	[storyMock1 verify];

	NSArray *successfulStories = [listener storiesWithStatus:SIStoryStatusSuccess];
	GHAssertNotNil(successfulStories, nil);
	GHAssertEquals([successfulStories count], (NSUInteger) 1, nil);
	GHAssertEquals([successfulStories lastObject], storyMock1, nil);
	
}

-(void) testReceivesNotifications {
	
	SIResultListener *listener = [[[SIResultListener alloc] init] autorelease];
	
	id storyMock1 = [OCMockObject mockForClass:[SIStory class]];
	SIStoryStatus status = SIStoryStatusSuccess;
	[[[storyMock1 expect] andReturnValue:OCMOCK_VALUE(status)] status];
	NSDictionary *userData = [NSDictionary dictionaryWithObject:storyMock1 forKey:SI_NOTIFICATION_KEY_STORY];
	NSNotification *story1Notification = [NSNotification notificationWithName:SI_STORY_EXECUTED_NOTIFICATION object:self userInfo:userData];

	[[NSNotificationCenter defaultCenter] postNotification:story1Notification];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	
	[storyMock1 verify];
	
	NSArray *successfulStories = [listener storiesWithStatus:SIStoryStatusSuccess];
	GHAssertEquals([successfulStories lastObject], storyMock1, nil);
	
}

@end
