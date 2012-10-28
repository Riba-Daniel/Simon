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
	SIStep *step;
}
@end

@implementation SIStepTests

-(void) setUp {
	step = [[SIStep alloc] initWithKeyword:SIKeywordGiven command:@"abc"];
}

-(void) tearDown {
	DC_DEALLOC(step);
}

-(void) testStoresKeywordAndCommand {
	GHAssertEquals(step.keyword, SIKeywordGiven, @"Keyword not returned");
	GHAssertEqualStrings(step.command,	@"abc", @"command not returned");
}

-(void) testFindsMapping {
	
	NSError *error = nil;
	SIStepMapping * mapping = [SIStepMapping stepMappingWithClass:[self class] selector:@selector(setUp) regex:@"abc" error:&error];
	GHAssertNotNil(mapping, @"Mapping not returned, error says %@", error.localizedDescription);
	NSArray * mappings = [NSArray arrayWithObject:mapping];
	
	[step findMappingInList:mappings];
	
	GHAssertTrue([step isMapped], @"Step did not find a mapping.");
}

-(void) testDoesNotFindMapping {
	
	NSError *error = nil;
	SIStepMapping * mapping = [SIStepMapping stepMappingWithClass:[self class] selector:@selector(setUp) regex:@"xyz" error:&error];
	GHAssertNotNil(mapping, @"Mapping not returned, error says %@", error.localizedDescription);
	NSArray * mappings = [NSArray arrayWithObject:mapping];
	
	[step findMappingInList:mappings];
	
	GHAssertFalse([step isMapped], @"Step should not have found a mapping.");
}

-(void) testCallsInvoke {
	
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

-(void) testInitWithJsonDictionary {
	
	NSDictionary *jsonData = @{@"keyword": @(SIKeywordGiven),
	@"command":@"hello",
	@"exception":@{
	@"name":@"exception_name",
	@"reason":@"exception_reason"
	},
	@"executed":@YES};

	SIStep *jsonStep = [[[SIStep alloc] initWithJsonDictionary:jsonData] autorelease];
	
	GHAssertEquals(jsonStep.keyword, SIKeywordGiven, nil);
	GHAssertEqualStrings(jsonStep.command, @"hello", nil);
	NSException *exception = jsonStep.exception;
	GHAssertEqualStrings(exception.name, @"exception_name", nil);
	GHAssertEqualStrings(exception.reason, @"exception_reason", nil);
	GHAssertTrue(jsonStep.executed, nil);
	
}

-(void) testJsonDictionary {
	
	step.executed = YES;
	step.exception = [NSException exceptionWithName:@"exception_name" reason:@"exception_reason" userInfo:nil];
	
	NSDictionary *jsonData = [step jsonDictionary];
	GHAssertEquals([[jsonData valueForKey:@"keyword"] intValue], SIKeywordGiven, nil);
	GHAssertEqualStrings([jsonData valueForKey:@"command"], @"abc", nil);
	GHAssertEqualStrings([jsonData valueForKeyPath:@"exception.name"], @"exception_name", nil);
	GHAssertEqualStrings([jsonData valueForKeyPath:@"exception.reason"], @"exception_reason", nil);
	GHAssertTrue([[jsonData valueForKey:@"executed"] boolValue], nil);
	
}

-(void) testStatusSuccess {
	step.stepMapping = [OCMockObject mockForClass:[SIStepMapping class]];
	step.executed = YES;
	GHAssertEquals(step.status, SIStepStatusSuccess, nil);
}

-(void) testStatusFailure {
	step.stepMapping = [OCMockObject mockForClass:[SIStepMapping class]];
	step.executed = YES;
	step.exception = [NSException exceptionWithName:@"abc" reason:@"reason" userInfo:nil];
	GHAssertEquals(step.status, SIStepStatusFailed, nil);
}

-(void) testStatusNotRun {
	step.stepMapping = [OCMockObject mockForClass:[SIStepMapping class]];
	GHAssertEquals(step.status, SIStepStatusNotRun, nil);
}

-(void) testStatusNotMapped {
	GHAssertEquals(step.status, SIStepStatusNotMapped, nil);
}

-(void) testStatusSuccessString {
	step.stepMapping = [OCMockObject mockForClass:[SIStepMapping class]];
	step.executed = YES;
	GHAssertEqualStrings(step.statusString, @"Success", nil);
}

-(void) testStatusFailureString {
	step.stepMapping = [OCMockObject mockForClass:[SIStepMapping class]];
	step.executed = YES;
	step.exception = [NSException exceptionWithName:@"abc" reason:@"reason" userInfo:nil];
	GHAssertEqualStrings(step.statusString, @"Failed", nil);
}

-(void) testStatusNotRunString {
	step.stepMapping = [OCMockObject mockForClass:[SIStepMapping class]];
	GHAssertEqualStrings(step.statusString, @"Not run", nil);
}

-(void) testStatusNotMappedString {
	GHAssertEqualStrings(step.statusString, @"Not mapped", nil);
}

@end
