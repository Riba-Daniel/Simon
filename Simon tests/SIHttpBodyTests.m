//
//  SIHttpResponseBodyTests.m
//  Simon
//
//  Created by Derek Clarkson on 29/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/SIHttpBody.h>

@interface SIHttpBodyTests : GHTestCase

@end

@implementation SIHttpBodyTests

-(void) testInitWithJsonDictionary {
	NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:SIHttpStatusError], RESPONSE_JSON_KEY_STATUS, @"Message", RESPONSE_JSON_KEY_MESSAGE, nil];
	SIHttpBody *body = [[[SIHttpBody alloc] initWithJsonDictionary:data] autorelease];
	GHAssertEquals(body.status, SIHttpStatusError, nil);
}

-(void) testJsonDictionary {
	SIHttpBody *body = [[[SIHttpBody alloc] init] autorelease];
	body.status = SIHttpStatusError;
	body.message = @"message";
	NSDictionary *data = [body jsonDictionary];
	GHAssertEquals([[data objectForKey:RESPONSE_JSON_KEY_STATUS] intValue], SIHttpStatusError, nil);
	GHAssertEquals([data objectForKey:RESPONSE_JSON_KEY_MESSAGE], @"message", nil);
}

@end
