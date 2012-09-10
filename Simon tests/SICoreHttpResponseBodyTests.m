//
//  SIHttpResponseBodyTests.m
//  Simon
//
//  Created by Derek Clarkson on 29/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/SICoreHttpSimpleResponseBody.h>

@interface SICoreHttpResponseBodyTests : GHTestCase

@end

@implementation SICoreHttpResponseBodyTests

-(void) testInitWithJsonDictionary {
	NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:SIHttpStatusError], RESPONSE_JSON_KEY_STATUS, nil];
	SICoreHttpSimpleResponseBody *body = [[[SICoreHttpSimpleResponseBody alloc] initWithJsonDictionary:data] autorelease];
	GHAssertEquals(body.status, SIHttpStatusError, nil);
}

-(void) testJsonDictionary {
	SICoreHttpSimpleResponseBody *body = [[[SICoreHttpSimpleResponseBody alloc] init] autorelease];
	body.status = SIHttpStatusError;
	NSDictionary *data = [body jsonDictionary];
	GHAssertEquals([[data objectForKey:RESPONSE_JSON_KEY_STATUS] intValue], SIHttpStatusError, nil);
}

@end
