//
//  SIAppBackpackTests.m
//  Simon
//
//  Created by Derek Clarkson on 5/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <OCMock/OCMock.h>
#import <OCMock/OCMArg.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIAppBackpack.h>
#import <Simon/SIConstants.h>
#import <Simon/SIStoryAnalyser.h>
#import <CocoaHTTPServer/HTTPServer.h>

// Hack into the process to update arguments for testing.
@interface NSProcessInfo (_hack)
- (void)setArguments:(id)arg1;
@end

@interface SIAppBackpackTests : GHTestCase {
@private
	NSArray *originalArgs;
	SIAppBackpack *backpack;
}
@end

@implementation SIAppBackpackTests

-(void) setUp {
	originalArgs = [[[NSProcessInfo processInfo] arguments] retain];
	backpack = [[SIAppBackpack alloc] init];
	[SIAppBackpack setBackpack:backpack];
}

-(void) tearDown {
	[[NSProcessInfo processInfo] setArguments: originalArgs];
	DC_DEALLOC(originalArgs);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	DC_DEALLOC(backpack);
}

-(void) testStartupLoadsStories {

	NSArray *args = [NSArray arrayWithObjects:ARG_AUTORUN, ARG_SHOW_UI, nil];
	[[NSProcessInfo processInfo] setArguments:args];

	NSNotification *notification = [NSNotification notificationWithName:UIApplicationDidBecomeActiveNotification object:self];
	
	id mockReader = [OCMockObject mockForClass:[SIStoryAnalyser class]];
	SIStoryGroupManager *storyGroupManager = [[[SIStoryGroupManager alloc] init] autorelease];
	SIStoryGroup *storyGroup = [[[SIStoryGroup alloc] init] autorelease];
	[storyGroupManager addStoryGroup:storyGroup];
	id mockStory = [OCMockObject mockForClass:[SIStory class]];
	[storyGroup addStory:mockStory];
	[[mockStory stub] reset];
	[[mockStory expect] mapSteps:[OCMArg any]];
	[[mockStory stub] invokeWithSource:storyGroup];

	//BOOL yes = YES;
	//[[[mockReader expect] andReturnValue:OCMOCK_VALUE(yes)] readstoryGroupManager:[OCMArg anyPointer]];
	[[[mockReader stub] andReturn:storyGroupManager] storyGroupManager];

	backpack.reader = mockReader;
	
	[backpack startUp:notification];
	
	// Need to give the code a change to execute.
	//[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	[NSThread sleepForTimeInterval:2.0];

	[mockReader verify];
	[mockStory verify];
	
	GHAssertTrue([backpack.storyGroupManager.storyGroups count] > 0, nil);
	
}

@end
