//
//  SIStoryRunnerTests.m
//  Simon
//
//  Created by Derek Clarkson on 6/17/11.
//  Copyright 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <OCMock/OCMock.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIStoryRunner.h>

@interface SIStoryRunnerTests : GHTestCase {
	@private
	BOOL startSent;
	BOOL endSent;
	SIStoryRunner *runner;
}
-(void) runStart:(NSNotification *) notification;
-(void) runEnd:(NSNotification *) notification;
@end

@implementation SIStoryRunnerTests

-(void) setUp {
	startSent = NO;
	endSent = NO;
	[[NSNotificationCenter defaultCenter] addObserver:self
														  selector:@selector(runStart:)
																name:SI_RUN_STARTING_NOTIFICATION
															 object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
														  selector:@selector(runEnd:)
																name:SI_RUN_FINISHED_NOTIFICATION
															 object:nil];
	runner = [[SIStoryRunner alloc] init];
}

-(void) tearDown {
	DC_DEALLOC(runner);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) testExecuting {
	
	SIStorySources *sources = [[[SIStorySources alloc] init] autorelease];
	SIStorySource *source = [[[SIStorySource alloc] init] autorelease];
	[sources addSource:source];
	id mockStory = [OCMockObject mockForClass:[SIStory class]];
	[[mockStory expect] reset];
	BOOL yes = YES;
	[[[mockStory expect] andReturnValue:OCMOCK_VALUE(yes)] invokeWithSource:source];
	[source addStory:mockStory];
	runner.storySources = sources;

	[runner run];
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	
	[mockStory verify];
	GHAssertTrue(startSent, nil);
	GHAssertTrue(endSent, nil);
}


-(void) runStart:(NSNotification *) notification {
	startSent = YES;
}

-(void) runEnd:(NSNotification *) notification {
	endSent = YES;
}

@end
