//
//  SIIncomingHttpConnectionTests.m
//  Simon
//
//  Created by Derek Clarkson on 26/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/SIIncomingHttpConnection.h>
#import <Simon/SIHttpRequestProcessor.h>
#import <OCMock/OCMock.h>
#import <dUsefulStuff/DCCommon.h>

@interface SIIncomingHttpConnection (_hack)
@property (retain, nonatomic) NSArray *processors;
@end

@interface SIIncomingHttpConnectionTests : GHTestCase {
	@private
	SIIncomingHttpConnection *connection;
	id processor1;
	id processor2;
	BOOL yes;
	BOOL no;
}

@end

@implementation SIIncomingHttpConnectionTests

-(void) setUp {
	yes = YES;
	no = YES;
	processor1 = [OCMockObject mockForProtocol:@protocol(SIHttpRequestProcessor)];
	processor2 = [OCMockObject mockForProtocol:@protocol(SIHttpRequestProcessor)];
	connection = [[SIIncomingHttpConnection alloc] initWithAsyncSocket:nil configuration:nil];

	// Override default setup.
	connection.processors = [NSArray arrayWithObjects:processor1, processor2, nil];
}

-(void) tearDown {
	[processor1 verify];
	[processor2 verify];
	DC_DEALLOC(connection);
}

-(void) testSupportsMethodAtPathChecksProcessors {
	
	[[[processor1 expect] andReturnValue:OCMOCK_VALUE(yes)] canProcessPath:@"/" withMethod:SIHttpMethodPost];
	[[[processor1 expect] andReturnValue:OCMOCK_VALUE(no)] canProcessPath:@"/" withMethod:SIHttpMethodPost];
	
	BOOL supports = [connection supportsMethod:@"post" atPath:@"/"];
	GHAssertTrue(supports, nil);
	
}

@end
