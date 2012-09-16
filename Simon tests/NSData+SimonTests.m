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
#import <Simon/SIHttpBody.h>

@interface NSData_SimonTests : GHTestCase

@end

@implementation NSData_SimonTests

-(void) testCreatesInstanceFromJsonData {
	NSData *data = DC_STRING_TO_DATA(@"{\"status\":\"OK\"}");
	id<SIJsonAware> obj = [data jsonToObject];
	GHAssertNotNil(obj, nil);
	GHAssertTrue([obj isKindOfClass:[SIHttpBody class]], nil);
}

@end
