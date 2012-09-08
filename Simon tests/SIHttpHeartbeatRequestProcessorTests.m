//
//  SIHttpRunAllRequestTests.m
//  Simon
//
//  Created by Derek Clarkson on 24/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import <GHUnitIOS/GHUnit.h>
#import <Simon/SIHttpHeartbeatRequestProcessor.h>

@interface SIHttpHeartbeatRequestProcessorTests : GHTestCase {
@private
	SIHttpHeartbeatRequestProcessor *processor;
}

@end

@implementation SIHttpHeartbeatRequestProcessorTests

-(void) setUp {
	processor = [[SIHttpHeartbeatRequestProcessor alloc] init];
}

-(void) tearDown {
	DC_DEALLOC(processor);
}

-(void) testCanProcessPathAndMethodWithCorrectRequest {
	GHAssertTrue([processor canProcessPath:HTTP_PATH_HEARTBEAT withMethod:SIHttpMethodGet], nil);
}

-(void) testCanProcessPathAndMethodWithOtherRequest {
	GHAssertFalse([processor canProcessPath:@"/xxx" withMethod:SIHttpMethodGet], nil);
}

-(void) testProcessPathWithMethodReturnsSuccess {
	
	id<HTTPResponse> response = [processor processPath:HTTP_PATH_HEARTBEAT withMethod:SIHttpMethodGet andBody:nil];
	NSString *actualResponse = DC_DATA_TO_STRING([response readDataOfLength:NSIntegerMax]);
	GHAssertEqualStrings(actualResponse, @"{\"status\":0}", nil);
}

@end
