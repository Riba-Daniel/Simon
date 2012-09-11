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
#import <Simon/SIStoryFileReader.h>
#import <CocoaHTTPServer/HTTPServer.h>

// Hack into the process to update arguments for testing.
@interface NSProcessInfo (_hack)
- (void)setArguments:(id)arg1;
@end

@interface SIAppBackpackTests : GHTestCase {
@private
	BOOL startRun;
	NSArray *originalArgs;
	SIAppBackpack *backpack;
}
@end

@implementation SIAppBackpackTests

-(void) setUp {
	originalArgs = [[[NSProcessInfo processInfo] arguments] retain];
	startRun = NO;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRun:) name:SI_RUN_STORIES_NOTIFICATION object:nil];
	backpack = [[SIAppBackpack alloc] init];
	[SIAppBackpack setBackpack:backpack];
}

-(void) tearDown {
	[[NSProcessInfo processInfo] setArguments: originalArgs];
	DC_DEALLOC(originalArgs);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	DC_DEALLOC(backpack);
}

-(void) testStartupLoadsStoriesAndFiresStartRunNotification {

	NSArray *args = [NSArray arrayWithObjects:ARG_AUTORUN, ARG_SHOW_UI, nil];
	[[NSProcessInfo processInfo] setArguments:args];

	NSNotification *notification = [NSNotification notificationWithName:UIApplicationDidBecomeActiveNotification object:self];
	
	id mockReader = [OCMockObject mockForClass:[SIStoryFileReader class]];
	SIStorySources *sources = [[[SIStorySources alloc] init] autorelease];
	SIStorySource *source = [[[SIStorySource alloc] init] autorelease];
	[sources addSource:source];
	id mockStory = [OCMockObject mockForClass:[SIStory class]];
	[source addStory:mockStory];
	[[mockStory stub] reset];
	[[mockStory expect] mapSteps:[OCMArg any]];
	[[mockStory stub] invokeWithSource:source];

	BOOL yes = YES;
	[[[mockReader expect] andReturnValue:OCMOCK_VALUE(yes)] readStorySources:[OCMArg anyPointer]];
	[[[mockReader stub] andReturn:sources] storySources];

	backpack.reader = mockReader;
	
	[backpack startUp:notification];
	
	// Need to give the code a change to execute.
	//[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	[NSThread sleepForTimeInterval:2.0];

	[mockReader verify];
	[mockStory verify];
	
	GHAssertTrue([backpack.storySources.sources count] > 0, nil);
	
}

@end
