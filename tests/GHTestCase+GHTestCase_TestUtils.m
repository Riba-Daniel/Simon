//
//  GHTestCase+GHTestCase_TestUtils.m
//  Simon
//
//  Created by Derek Clarkson on 9/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "GHTestCase+GHTestCase_TestUtils.h"
#import <OCMock/OCMock.h>
#import <Simon/SIStory.h>

@implementation GHTestCase (GHTestCase_TestUtils)

-(NSNotification *) createMockedNotification:(NSString *) name forStoryStatus:(SIStoryStatus) status {
	id storyMock = [OCMockObject mockForClass:[SIStory class]];
	[[[storyMock stub] andReturnValue:OCMOCK_VALUE(status)] status];
	NSDictionary *userData = [NSDictionary dictionaryWithObject:storyMock forKey:SI_NOTIFICATION_KEY_STORY];
	return [NSNotification notificationWithName:name object:self userInfo:userData];
}

@end
