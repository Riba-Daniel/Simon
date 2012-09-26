//
//  NSData+SimonTests.m
//  Simon
//
//  Created by Derek Clarkson on 17/09/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/NSData+Simon.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIHttpPayload.h>
#import <dUsefulStuff/NSError+dUsefulStuff.h>

@interface NSData_SimonTests : GHTestCase

@end

@implementation NSData_SimonTests

-(void) testJsonToObjectCreatesInstanceFromJsonData {
	NSError *error = nil;
	NSData *data = DC_STRING_TO_DATA(@"{\"status\":\"OK\"}");
	id<SIJsonAware> obj = [data jsonToObjectWithClass:[SIHttpPayload class] error:&error];
	GHAssertNotNil(obj, nil);
	GHAssertNil(error, [error localizedDescription]);
	GHAssertTrue([obj isKindOfClass:[SIHttpPayload class]], nil);
}

-(void) testJsonToObjectReturnsErrorWhenNotJsonData {
	NSError *error = nil;
	NSData *data = DC_STRING_TO_DATA(@"abc");
	id<SIJsonAware> obj = [data jsonToObjectWithClass:[SIHttpPayload class] error:&error];
	GHAssertNil(obj, nil);
	GHAssertNotNil(error, [error localizedDescription]);
	GHAssertEquals([error code], 3840, nil);
}

@end
