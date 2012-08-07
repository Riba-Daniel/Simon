//
//  SIStoryTests.m
//  Simon
//
//  Created by Derek Clarkson on 6/27/11.
//  Copyright 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>
#import <OCMock/OCMock.h>
#import <OCMock/OCMArg.h>
#import <Simon/SIStep.h>
#import <Simon/SIStory.h>
#import <Simon/SIStepMapping.h>
#import <Simon/SIStorySource.h>

@interface SIStoryTests : GHTestCase {
@private
	SIStorySource *source;
	SIStory *story;
	BOOL abcMethodCalled;
	BOOL defMethodCalled;
	BOOL startNotificationFired;
	BOOL finishedNotificationFired;
}

-(void) storyStarted:(NSNotification *) notification;
-(void) storyExecuted:(NSNotification *) notification;
@end

@implementation SIStoryTests

-(void) setUp {
	source = [[SIStorySource alloc] init];
	story = [[SIStory alloc] init];
	finishedNotificationFired = NO;
	startNotificationFired = NO;
	abcMethodCalled = NO;
	defMethodCalled = NO;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storyStarted:) name:SI_STORY_STARTING_EXECUTION_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storyExecuted:) name:SI_STORY_EXECUTED_NOTIFICATION object:nil];
}

-(void) tearDown {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	DC_DEALLOC(story);
	DC_DEALLOC(source);
}

-(void) testInvokeFiresNotification {
	
	BOOL success = [story invokeWithSource:source];
	
	// Allow the notification to be sent.
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	
	GHAssertTrue(success, @"Invoked should have worked");
	GHAssertTrue(startNotificationFired, @"Notification not sent.");
	GHAssertTrue(finishedNotificationFired, @"Notification not sent.");
	
}


-(void) testInvokeReturnsStatusIfStepIsNotMapped {
	
	[story createStepWithKeyword:SIKeywordGiven command:@"abc"];
	
	BOOL success = [story invokeWithSource:source];
	
	GHAssertFalse(success, @"Invoked should have failed");
	GHAssertEquals(story.status, SIStoryStatusNotMapped, @"Incorrect status returned");
	
}

-(void) testInvokeReturnsOk {
	
	SIStep *step = [story createStepWithKeyword:SIKeywordGiven command:@"abc"];
	
	NSError * error = nil;
	
	SIStepMapping * mapping = [SIStepMapping stepMappingWithClass:[SIStoryTests class] selector:@selector(abc) regex:@"abc" error:&error];
	GHAssertNotNil(mapping, @"Mapping should not be nil, error %@", error.localizedDescription);
	step.stepMapping = mapping;
	
	BOOL success = [story invokeWithSource:source];
	
	GHAssertTrue(success, @"Invoked should have worked. Error %@", story.error.localizedFailureReason);
	GHAssertNil(story.error, @"Error not nil. Error %@", error.localizedFailureReason);
	GHAssertEquals(story.status, SIStoryStatusSuccess, @"Success code not returned");
}

-(void) testInvokeGivesStatusNotMapped {
	
	[story createStepWithKeyword:SIKeywordGiven command:@"abc"];
	
	BOOL success = [story invokeWithSource:source];
	
	GHAssertFalse(success, @"Invocation should be false");
	GHAssertNil(story.error, @"Error not nil. Error %@", story.error.localizedFailureReason);
	GHAssertEquals(story.status, SIStoryStatusNotMapped, @"incorrect story status");
}

-(void) testInvocationSharesClassInstance {
	
	SIStep *step1 = [story createStepWithKeyword:SIKeywordGiven command:@"abc"];
	SIStep *step2 = [story createStepWithKeyword:SIKeywordGiven command:@"def"];
	
	NSError * error = nil;
	
	SIStepMapping * mapping1 = [SIStepMapping stepMappingWithClass:[SIStoryTests class] selector:@selector(abc) regex:@"abc" error:&error];
	GHAssertNotNil(mapping1, @"Mapping should not be nil, error %@", error.localizedDescription);

	SIStepMapping * mapping2 = [SIStepMapping stepMappingWithClass:[SIStoryTests class] selector:@selector(def) regex:@"def" error:&error];
	GHAssertNotNil(mapping2, @"Mapping should not be nil, error %@", error.localizedDescription);

	step1.stepMapping = mapping1;
	step2.stepMapping = mapping2;
	
	BOOL success = [story invokeWithSource:source];
	
	GHAssertTrue(success, @"Invoked should have worked. Error %@", story.error.localizedFailureReason);
	GHAssertNil(story.error, @"Error not nil. Error %@", story.error.localizedFailureReason);
	GHAssertEquals(story.status, SIStoryStatusSuccess, @"Success code not returned");

}

// Used for testing.
-(void) abc {
	DC_LOG(@"Executing abc");
	abcMethodCalled = YES;
}

-(void) def {
	DC_LOG(@"Executing def");
	defMethodCalled = YES;
	GHAssertTrue(abcMethodCalled, @"Appear to in a different instance of the class.");
}

-(void) storyStarted:(NSNotification *) notification {
	DC_LOG(@"Story starting notification received");
	startNotificationFired = YES;
	NSDictionary *userData = [notification userInfo];
	GHAssertTrue([[userData allKeys] containsObject:SI_NOTIFICATION_KEY_SOURCE], nil);
	GHAssertTrue([[userData allKeys] containsObject:SI_NOTIFICATION_KEY_STORY], nil);
	GHAssertEquals([userData valueForKey:SI_NOTIFICATION_KEY_SOURCE], source, nil);
	GHAssertEquals([userData valueForKey:SI_NOTIFICATION_KEY_STORY], story, nil);
}

-(void) storyExecuted:(NSNotification *) notification {
	DC_LOG(@"Story executed notification received");
	finishedNotificationFired = YES;
	NSDictionary *userData = [notification userInfo];
	GHAssertTrue([[userData allKeys] containsObject:SI_NOTIFICATION_KEY_SOURCE], nil);
	GHAssertTrue([[userData allKeys] containsObject:SI_NOTIFICATION_KEY_STORY], nil);
	GHAssertEquals([userData valueForKey:SI_NOTIFICATION_KEY_SOURCE], source, nil);
	GHAssertEquals([userData valueForKey:SI_NOTIFICATION_KEY_STORY], story, nil);
}

@end
