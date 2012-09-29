//
//  SIHttpPostRequestHandlerTests.m
//  Simon
//
//  Created by Derek Clarkson on 26/09/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/SIHttpPostRequestHandler.h>
#import <Simon/SIHttpPayload.h>
#import <dUsefulStuff/DCCommon.h>
#import <CocoaHTTPServer/HTTPDataResponse.h>

@interface SIHttpPostRequestHandlerTests : GHTestCase {
@private
	SIHttpPostRequestHandler *handler;
	BOOL processCalled;
	NSData *body;
	BOOL requestPayloadCorrect;
}

@end

@implementation SIHttpPostRequestHandlerTests

-(void) setUp {
	processCalled = NO;
	requestPayloadCorrect = NO;
	handler = [[SIHttpPostRequestHandler alloc] initWithPath:@"abc"
														 requestBodyClass:[SIHttpPayload class]
																	 process:^id<SIJsonAware>(id<SIJsonAware> bodyObj) {
																		 processCalled = YES;
																		 requestPayloadCorrect = bodyObj != nil
																		 && [bodyObj isKindOfClass:[SIHttpPayload class]]
																		 && ((SIHttpPayload *) bodyObj).status == SIHttpStatusError;
																		 return [[SIHttpPayload alloc] initWithStatus:SIHttpStatusError message:@"xyz"];
																	 }];
	const char *bodyContent = "{\"status\":1}";
	body = [[NSData dataWithBytes:bodyContent length:strlen(bodyContent)] retain];
}

-(void) tearDown {
	DC_DEALLOC(handler);
	DC_DEALLOC(body);
}

-(void) testOnlyAcceptsPostRequests {
	GHAssertFalse([handler canProcessPath:@"abc" withMethod:SIHttpMethodGet], nil);
	GHAssertTrue([handler canProcessPath:@"abc" withMethod:SIHttpMethodPost], nil);
}

-(void) testOnlyAcceptsCorrectPath {
	GHAssertTrue([handler canProcessPath:@"abc" withMethod:SIHttpMethodPost], nil);
	GHAssertFalse([handler canProcessPath:@"xyz" withMethod:SIHttpMethodPost], nil);
}

-(void) testDoesExpectABody {
	GHAssertTrue([handler expectingHttpBody], nil);
}

-(void) testCallsProcess {
	[handler processPath:@"abc" andBody:body];
	GHAssertTrue(processCalled, nil);
	GHAssertTrue(requestPayloadCorrect, nil);
}

-(void) testProcessReturnsHttpResponse {
	HTTPDataResponse *response = (HTTPDataResponse *)[handler processPath:@"abc" andBody:body];
	GHAssertNotNil(response, nil);
	NSData *responseBody = [response readDataOfLength:[response contentLength]];
	GHAssertEqualStrings(DC_DATA_TO_STRING(responseBody), @"{\"status\":1,\"message\":\"xyz\"}", nil);
}

-(void) testProcessGeneratesHttpResponse {
	
	DC_DEALLOC(handler);
	handler = [[SIHttpPostRequestHandler alloc] initWithPath:@"abc"
														 requestBodyClass:[SIHttpPayload class]
																	 process:^id<SIJsonAware>(id<SIJsonAware> bodyObj) {
																		 return nil;
																	 }];
	
	HTTPDataResponse *response = (HTTPDataResponse *)[handler processPath:@"abc" andBody:body];
	GHAssertNotNil(response, nil);
	NSData *responseBody = [response readDataOfLength:[response contentLength]];
	GHAssertEqualStrings(DC_DATA_TO_STRING(responseBody), @"{\"status\":0,\"message\":null}", nil);
}


@end
