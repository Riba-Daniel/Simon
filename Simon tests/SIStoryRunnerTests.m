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
#import "TestUtils.h"
#import <objc/runtime.h>

@interface SIStoryRunnerTests : GHTestCase {
@private
	BOOL startSent;
	BOOL endSent;
	SIStoryRunner *runner;
	SIStorySources *sources;
	SIStorySource *source1;
	SIStorySource *source2;
	id mockStory1;
	id mockStory2;
	id mockStory3;
	
}
-(void) runStart:(NSNotification *) notification;
-(void) runEnd:(NSNotification *) notification;

+ (NSData *)dummySendSynchronousRequest:(NSURLRequest *)request
							 returningResponse:(NSURLResponse **)response
											 error:(NSError **)error;

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
	
	sources = [[SIStorySources alloc] init];
	
	source1 = [[SIStorySource alloc] init];
	[sources addSource:source1];
	
	source2 = [[SIStorySource alloc] init];
	[sources addSource:source2];
	
	mockStory1 = [OCMockObject mockForClass:[SIStory class]];
	[source1 addStory:mockStory1];
	
	mockStory2 = [OCMockObject mockForClass:[SIStory class]];
	[source2 addStory:mockStory2];
	
	mockStory3 = [OCMockObject mockForClass:[SIStory class]];
	[source2 addStory:mockStory3];
	
	runner = [[SIStoryRunner alloc] init];
	runner.storySources = sources;
	
	// Swizzle the comms.
	SEL dummySelector = @selector(dummySendSynchronousRequest:returningResponse:error:);
	IMP impl = class_getMethodImplementation([SIStoryRunnerTests class], dummySelector);
	[TestUtils swizzleNSURLConnectionSendSyncWithImp:impl];
}

-(void) tearDown {
	[TestUtils restoreNSURLConnectionSendSync];
	[mockStory1 verify];
	[mockStory2 verify];
	[mockStory3 verify];
	DC_DEALLOC(runner);
	DC_DEALLOC(sources);
	DC_DEALLOC(source1);
	DC_DEALLOC(source2);
	DC_DEALLOC(mockStory1);
	DC_DEALLOC(mockStory2);
	DC_DEALLOC(mockStory3);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) testExecutingAllStories {
	
	[[mockStory1 expect] reset];
	[[mockStory2 expect] reset];
	[[mockStory3 expect] reset];
	BOOL yes = YES;
	[[[mockStory1 expect] andReturnValue:OCMOCK_VALUE(yes)] invokeWithSource:source1];
	[[[mockStory2 expect] andReturnValue:OCMOCK_VALUE(yes)] invokeWithSource:source2];
	[[[mockStory3 expect] andReturnValue:OCMOCK_VALUE(yes)] invokeWithSource:source2];
	
	[runner run];
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
	[NSThread sleepForTimeInterval:0.2];
	
	GHAssertTrue(startSent, nil);
	GHAssertTrue(endSent, nil);
}

-(void) testRunCurrentStoryOnly {
	[[mockStory2 expect] reset];
	BOOL yes = YES;
	[[[mockStory2 expect] andReturnValue:OCMOCK_VALUE(yes)] invokeWithSource:source2];
	
	NSIndexPath *currentStory = [NSIndexPath indexPathForRow:0 inSection:1];
	sources.currentIndexPath = currentStory;
	[runner run];
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
	[NSThread sleepForTimeInterval:0.2];
	
	GHAssertTrue(startSent, nil);
	GHAssertTrue(endSent, nil);
}

-(void) runStart:(NSNotification *) notification {
	startSent = YES;
}

-(void) runEnd:(NSNotification *) notification {
	endSent = YES;
}

+ (NSData *)dummySendSynchronousRequest:(NSURLRequest *)request
							 returningResponse:(NSURLResponse **)response
											 error:(NSError **)error {
	// Don't do anything except return a basic response.
	DC_LOG(@"Executing dummy impl of sendSynchronousRequest:returningResponse:error:");
	return DC_STRING_TO_DATA(@"{\"status\":\"0\"}");
}

@end
