//
//  SIStoryRunnerTests.m
//  Simon
//
//  Created by Derek Clarkson on 6/17/11.
//  Copyright 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIStoryRunner.h>
#import <Simon/Simon.h>
#import <Simon/SIStoryLogger.h>

@interface SIStoryFileReader ()
-(BOOL) readFile:(NSString *) filename error:(NSError **) error;
@end

@interface SIStoryRunnerTests : GHTestCase {
@private
	BOOL step1Called;
	BOOL step2Called;
	BOOL step3Called;
}
-(void) stepAs:(NSString *) name;
-(void) stepGivenThisFileExists;
-(void) stepThenIShouldBeAbleToRead:(NSNumber *) aNumber and:(NSString *) aString;
@end

@implementation SIStoryRunnerTests

-(void) testRunStories {
	SIStoryFileReader *reader = [[[SIStoryFileReader alloc] init] autorelease];
	reader.storySources = [NSMutableArray array];
	SIStoryRunner *runner = [[[SIStoryRunner alloc] init] autorelease];
	NSError *error = nil;
	[reader readFile:@"Story files" error:&error];
	runner.reader = reader;
	[runner run];
}

-(void) testIsAbleToPassValuesBetweenClassInstances {
	SIStoryFileReader *reader = [[[SIStoryFileReader alloc] init] autorelease];
	reader.storySources = [NSMutableArray array];
	SIStoryRunner *runner = [[[SIStoryRunner alloc] init] autorelease];
	NSError *error = nil;
	[reader readFile:@"Communication" error:&error];
	runner.reader = reader;
	[runner run];
}

// ### Methods which are called by Simon ###

SIMapStepToSelector(@"As ([A-Z][a-z]+)", stepAs:)
-(void) stepAs:(NSString *) name {
	DC_LOG(@"As %@", name);
	GHAssertEqualStrings(name, @"Simon", @"Incorrect name passed to step.");
	step1Called = YES;
}

SIMapStepToSelector(@"Given this file exists", stepGivenThisFileExists)
-(void) stepGivenThisFileExists {
	DC_LOG(@"Given this file exists");
	GHAssertTrue(step1Called, @"Step 1 not called");
	step2Called = YES;
}

SIMapStepToSelector(@"then I should be able to read (\\d+) and ([a-z]+) from it", stepThenIShouldBeAbleToRead:and:)
-(void) stepThenIShouldBeAbleToRead:(NSNumber *) aNumber and:(NSString *) aString {
	DC_LOG(@"Then I should be able to read %f and %@", [aNumber floatValue], aString);
	GHAssertEquals([aNumber floatValue], (float) 5.0, @"Incorrect float value passed to step.");
	GHAssertEqualStrings(aString, @"abc", @"Incorrect value passed to step.");
	GHAssertTrue(step1Called, @"Step 1 not called");
	GHAssertTrue(step2Called, @"Step 2 not called");
	step3Called = YES;
}

@end
