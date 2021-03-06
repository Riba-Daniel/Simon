//
//  GHTestCase+GHTestCase_TestUtils.m
//  Simon
//
//  Created by Derek Clarkson on 9/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "GHTestCase+Utils.h"
#import <OCMock/OCMock.h>
#import <Simon/SIStory.h>

@implementation GHTestCase (Utils)

-(NSNotification *) createMockedNotification:(NSString *) name forStoryStatus:(SIStoryStatus) status {

	id storyMock = [OCMockObject niceMockForClass:[SIStory class]];

	// Turn of strict selector match diagnostic because GHTestCase as a status method and the compiler doesn't know which to use.
#pragma GCC diagnostic ignored "-Wstrict-selector-match"
	[[[storyMock stub] andReturnValue:OCMOCK_VALUE(status)] status];
#pragma GCC diagnostic warning "-Wstrict-selector-match"
	
	NSDictionary *userData = [NSDictionary dictionaryWithObject:storyMock forKey:SI_NOTIFICATION_KEY_STORY];
	return [NSNotification notificationWithName:name object:self userInfo:userData];
}

@end
