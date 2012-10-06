//
//  SIHttpGetREquestHandlerTests.m
//  Simon
//
//  Created by Derek Clarkson on 26/09/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/SIHttpGetRequestHandler.h>
#import <Simon/SIHttpPayload.h>
#import <dUsefulStuff/DCCommon.h>
#import <CocoaHTTPServer/HTTPResponse.h>

@interface SIHttpGetRequestHandlerTests : GHTestCase {
@private
	SIHttpGetRequestHandler *handler;
	BOOL processCalled;
}

@end

@implementation SIHttpGetRequestHandlerTests

-(void) setUp {
	processCalled = NO;
	handler = [[SIHttpGetRequestHandler alloc] initWithPath:@"abc"
																	process:^id<SIJsonAware>(id<SIJsonAware> bodyObj) {
																		processCalled = YES;
																		return [[[SIHttpPayload alloc] initWithStatus:SIHttpStatusError message:@"xyz"] autorelease];
																	}];
}

-(void) tearDown {
	DC_DEALLOC(handler);
}

-(void) testOnlyAcceptsGetRequests {
	GHAssertTrue([handler canProcessPath:@"abc" withMethod:SIHttpMethodGet], nil);
	GHAssertFalse([handler canProcessPath:@"abc" withMethod:SIHttpMethodPost], nil);
}

-(void) testOnlyAcceptsCorrectPath {
	GHAssertTrue([handler canProcessPath:@"abc" withMethod:SIHttpMethodGet], nil);
	GHAssertFalse([handler canProcessPath:@"xyz" withMethod:SIHttpMethodGet], nil);
}

-(void) testDoesntExpectABody {
	GHAssertFalse([handler expectingHttpBody], nil);
}

-(void) testCallsProcess {
	[handler processPath:@"abc" andBody:nil];
	GHAssertTrue(processCalled, nil);
}

-(void) testProcessReturnsHttpResponse {
	id<HTTPResponse> response = [handler processPath:@"abc" andBody:nil];
	GHAssertNotNil(response, nil);
}

@end
