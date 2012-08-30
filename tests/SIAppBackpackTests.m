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
@interface NSProcessInfo (SIAppBackpackTests)
- (void)setArguments:(id)arg1;
@end

@interface SIAppBackpackTests : GHTestCase {
@private
	BOOL startRun;
	NSArray *originalArgs;
}
-(void) startRun:(NSNotification *) notification;
@end

@implementation SIAppBackpackTests

-(void) setUp {
	originalArgs = [[[NSProcessInfo processInfo] arguments] retain];
	startRun = NO;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRun:) name:SI_RUN_STORIES_NOTIFICATION object:nil];
}

-(void) tearDown {
	[[NSProcessInfo processInfo] setArguments: originalArgs];
	DC_DEALLOC(originalArgs);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) testStartupLoadsStoriesAndFiresStartRunNotification {

	NSArray *args = [NSArray arrayWithObjects:@"--autorun", nil];
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

	[SIAppBackpack backpack].reader = mockReader;
	
	[[SIAppBackpack backpack] startUp:notification];
	
	// Need to give the code a change to execute.
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	[NSThread sleepForTimeInterval:2.0];

	[mockReader verify];
	[mockStory verify];
	
	GHAssertTrue(startRun, nil);
	GHAssertTrue([[SIAppBackpack backpack].storySources.sources count] > 0, nil);
	
}

-(void) testPresenceOfArg {
	NSArray *args = [NSArray arrayWithObjects:@"--hello", nil];
	[[NSProcessInfo processInfo] setArguments:args];
	GHAssertTrue([SIAppBackpack isArgumentPresentWithName:@"hello"], nil);
}

-(void) testRetrieveArgValue {
	NSArray *args = [NSArray arrayWithObjects:@"--hello", @"abc", nil];
	[[NSProcessInfo processInfo] setArguments:args];
	GHAssertTrue([SIAppBackpack isArgumentPresentWithName:@"hello"], nil);
	NSString *argValue = [SIAppBackpack argumentValueForName:@"hello"];
	GHAssertEqualStrings(argValue, @"abc", nil);
}

-(void) testRetrieveArgValueNilWhenNotPresent {
	NSArray *args = [NSArray arrayWithObjects:@"--hello", nil];
	[[NSProcessInfo processInfo] setArguments:args];
	GHAssertTrue([SIAppBackpack isArgumentPresentWithName:@"hello"], nil);
	NSString *argValue = [SIAppBackpack argumentValueForName:@"hello"];
	GHAssertNil(argValue, nil);
}

-(void) testRetrieveArgValueNilWhenValueIsNextArg {
	NSArray *args = [NSArray arrayWithObjects:@"--hello", @"--there", nil];
	[[NSProcessInfo processInfo] setArguments:args];
	GHAssertTrue([SIAppBackpack isArgumentPresentWithName:@"hello"], nil);
	NSString *argValue = [SIAppBackpack argumentValueForName:@"hello"];
	GHAssertNil(argValue, nil);
}

// Handlers.

-(void) startRun:(NSNotification *) notification {
	startRun = YES;
}

@end
