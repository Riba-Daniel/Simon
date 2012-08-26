//
//  SIIncomingHttpConnectionTests.m
//  Simon
//
//  Created by Derek Clarkson on 26/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/SIHttpIncomingConnection.h>
#import <Simon/SIHttpRequestProcessor.h>
#import <OCMock/OCMock.h>
#import <dUsefulStuff/DCCommon.h>

@interface SIHttpIncomingConnection (_hack)
@property (retain, nonatomic) NSArray *processors;
@end

@interface SIHttpIncomingConnectionTests : GHTestCase {
	@private
	SIHttpIncomingConnection *connection;
	id processor1;
	id processor2;
	BOOL yes;
	BOOL no;
}

@end

@implementation SIHttpIncomingConnectionTests

-(void) setUp {
	yes = YES;
	no = NO;
	processor1 = [OCMockObject mockForProtocol:@protocol(SIHttpRequestProcessor)];
	processor2 = [OCMockObject mockForProtocol:@protocol(SIHttpRequestProcessor)];
	connection = [[SIHttpIncomingConnection alloc] initWithAsyncSocket:nil configuration:nil];

}

-(void) tearDown {
	[processor1 verify];
	[processor2 verify];
	DC_DEALLOC(connection);
}

-(void) testSupportsMethodAtPathChecksProcessors {

	// Override default setup.
	connection.processors = [NSArray arrayWithObjects:processor1, processor2, nil];
	
	[[[processor1 expect] andReturnValue:OCMOCK_VALUE(no)] canProcessPath:@"/" withMethod:SIHttpMethodPost];
	[[[processor2 expect] andReturnValue:OCMOCK_VALUE(yes)] canProcessPath:@"/" withMethod:SIHttpMethodPost];
	
	BOOL supports = [connection supportsMethod:@"post" atPath:@"/"];
	GHAssertTrue(supports, nil);
	
}

-(void) testExpectingMethodBody {
	
	// Override default setup.
	connection.processors = [NSArray arrayWithObjects:processor1, processor2, nil];
	
	[[[processor1 expect] andReturnValue:OCMOCK_VALUE(yes)] canProcessPath:@"/" withMethod:SIHttpMethodPost];
	[[[processor1 expect] andReturnValue:OCMOCK_VALUE(yes)] expectingHttpBody];
	
	BOOL supports = [connection expectsRequestBodyFromMethod:@"post" atPath:@"/"];
	GHAssertTrue(supports, nil);
	
}

-(void) testExpectingMethodBodyWithNoExpectedBody {
	
	// Override default setup.
	connection.processors = [NSArray arrayWithObjects:processor1, processor2, nil];
	
	[[[processor1 expect] andReturnValue:OCMOCK_VALUE(no)] canProcessPath:@"/" withMethod:SIHttpMethodPost];
	[[[processor2 expect] andReturnValue:OCMOCK_VALUE(yes)] canProcessPath:@"/" withMethod:SIHttpMethodPost];
	[[[processor2 expect] andReturnValue:OCMOCK_VALUE(no)] expectingHttpBody];
	
	BOOL supports = [connection expectsRequestBodyFromMethod:@"post" atPath:@"/"];
	GHAssertFalse(supports, nil);
	
}

@end
