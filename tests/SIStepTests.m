//
//  SIStepStories.m
//  Simon
//
//  Created by Derek Clarkson on 6/14/11.
//  Copyright 2011. All rights reserved.
//


#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>
#import <OCMock/OCMock.h>
#import <Simon/SIStep.h>

@interface SIStepTests : GHTestCase {
@private
}
@end

@implementation SIStepTests

-(void) setUp {
}

-(void) testStoresKeywordAndCommand {
	SIStep * step = [[[SIStep alloc] initWithKeyword:SIKeywordGiven command:@"abc"] autorelease];
	GHAssertEquals(step.keyword, SIKeywordGiven, @"Keyword not returned");
	GHAssertEqualStrings(step.command,	@"abc", @"command not returned");
}

-(void) testFindsMapping {
	
	SIStep * step = [[[SIStep alloc] initWithKeyword:SIKeywordGiven command:@"abc"] autorelease];
	NSError *error = nil;
	SIStepMapping * mapping = [SIStepMapping stepMappingWithClass:[self class] selector:@selector(setUp) regex:@"abc" error:&error];
	GHAssertNotNil(mapping, @"Mapping not returned, error says %@", error.localizedDescription);
	NSArray * mappings = [NSArray arrayWithObject:mapping];

	[step findMappingInList:mappings];
	
	GHAssertTrue([step isMapped], @"Step did not find a mapping.");
}

-(void) testDoesNotFindMapping {
	
	SIStep * step = [[[SIStep alloc] initWithKeyword:SIKeywordGiven command:@"abc"] autorelease];
	NSError *error = nil;
	SIStepMapping * mapping = [SIStepMapping stepMappingWithClass:[self class] selector:@selector(setUp) regex:@"xyz" error:&error];
	GHAssertNotNil(mapping, @"Mapping not returned, error says %@", error.localizedDescription);
	NSArray * mappings = [NSArray arrayWithObject:mapping];
	
	[step findMappingInList:mappings];
	
	GHAssertFalse([step isMapped], @"Step should not have found a mapping.");
}

-(void) testCallsInvoke {
	
	SIStep * step = [[[SIStep alloc] initWithKeyword:SIKeywordGiven command:@"abc"] autorelease];

	NSError *error = nil;
	BOOL yes = YES;
	
	id mockMapping = [OCMockObject mockForClass:[SIStepMapping class]];
	[[[mockMapping expect] andReturnValue:OCMOCK_VALUE(yes)] invokeWithCommand:@"abc" object:self error:&error];
	
	step.stepMapping = mockMapping;
	[step invokeWithObject:self error:&error];
	
	GHAssertTrue(step.executed, @"Executed flag incorrect");

	[mockMapping verify];
	
}

-(void) testCallsInvokeAndDetectsException {
	
	SIStep * step = [[[SIStep alloc] initWithKeyword:SIKeywordGiven command:@"abc"] autorelease];
	
	NSError *error = nil;
	
	id mockMapping = [OCMockObject mockForClass:[SIStepMapping class]];
	[[[mockMapping expect] andThrow:[NSException exceptionWithName:@"test" reason:@"test" userInfo:nil]] invokeWithCommand:@"abc" object:self error:&error];
	
	step.stepMapping = mockMapping;
	BOOL success = [step invokeWithObject:self error:&error];
	
	GHAssertTrue(step.executed, @"Executed flag incorrect");
	GHAssertFalse(success, @"Step did not indicate an error");
	GHAssertNotNil(error, @"Error not populated");
	GHAssertEqualStrings([error localizedFailureReason], @"Exception caught: test", @"reason not returned.");
	GHAssertEqualStrings([error domain], @"SIError", @"Incorrect domain.");
	GHAssertEqualStrings([error localizedDescription], @"Exception caught", @"description incorrect.");
	
	[mockMapping verify];
	
}

@end
