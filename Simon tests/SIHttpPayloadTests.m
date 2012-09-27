//
//  SIHttpResponseBodyTests.m
//  Simon
//
//  Created by Derek Clarkson on 29/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/SIHttpPayload.h>

@interface SIHttpPayloadTests : GHTestCase

@end

@implementation SIHttpPayloadTests

-(void) testDefaultInitialiser {
	SIHttpPayload *body = [[[SIHttpPayload alloc] initWithStatus:SIHttpMethodPost message:@"abc"] autorelease];
	GHAssertEquals(body.status, SIHttpMethodPost, nil);
	GHAssertEqualStrings(body.message, @"abc", nil);
}

-(void) testFactoryMethod {
	SIHttpPayload *body = [SIHttpPayload httpPayloadWithStatus:SIHttpMethodPost message:@"abc"];
	GHAssertEquals(body.status, SIHttpMethodPost, nil);
	GHAssertEqualStrings(body.message, @"abc", nil);
}

-(void) testInitWithJsonDictionary {
	NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:SIHttpStatusError], PAYLOAD_KEY_STATUS, @"Message", PAYLOAD_KEY_MESSAGE, nil];
	SIHttpPayload *body = [[[SIHttpPayload alloc] initWithJsonDictionary:data] autorelease];
	GHAssertEquals(body.status, SIHttpStatusError, nil);
}

-(void) testJsonDictionary {
	SIHttpPayload *body = [[[SIHttpPayload alloc] init] autorelease];
	body.status = SIHttpStatusError;
	body.message = @"message";
	NSDictionary *data = [body jsonDictionary];
	GHAssertEquals([[data objectForKey:PAYLOAD_KEY_STATUS] intValue], SIHttpStatusError, nil);
	GHAssertEquals([data objectForKey:PAYLOAD_KEY_MESSAGE], @"message", nil);
}

@end
