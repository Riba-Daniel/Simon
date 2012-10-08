//
//  PIReporterTests.m
//  Simon
//
//  Created by Derek Clarkson on 8/10/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "PIReporter.h"
#import <dUsefulStuff/DCCommon.h>
//#import "NSNotificationCenter.h"

@interface DummyReport : PIReporter
@property (nonatomic) BOOL storyFinishedCalled;
@property (nonatomic) BOOL runFinishedCalled;
@end

@implementation DummyReport

@synthesize storyFinishedCalled = _storyFinishedCalled;
@synthesize runFinishedCalled = _runFinishedCalled;

-(void) storyFinished:(SIStory *) story {
	self.storyFinishedCalled = YES;
}

-(void) runFinished:(SIFinalReport *) report {
	self.runFinishedCalled = YES;
}

@end

// --------------------------------
#pragma mark - Tests

@interface PIReporterTests : GHTestCase {
	@private
	DummyReport *dummyReport;
}

@end

@implementation PIReporterTests

-(void) setUp {
	dummyReport = [[DummyReport alloc] init];
}

-(void) tearDown {
	DC_DEALLOC(dummyReport);
}

-(void) testHandlesStoryFinished {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center postNotificationName:PI_STORY_FINISHED_NOTIFICATION object:self userInfo:nil];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	GHAssertTrue(dummyReport.storyFinishedCalled, nil);
	GHAssertFalse(dummyReport.runFinishedCalled, nil);
}

-(void) testHandlesRunFinished {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center postNotificationName:PI_RUN_FINISHED_NOTIFICATION object:self];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	GHAssertFalse(dummyReport.storyFinishedCalled, nil);
	GHAssertTrue(dummyReport.runFinishedCalled, nil);
}

@end
