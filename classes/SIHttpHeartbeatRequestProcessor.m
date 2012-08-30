//
//  SIHttpHeartbeatRequestProcessor.m
//  Simon
//
//  Created by Derek Clarkson on 27/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIHttpHeartbeatRequestProcessor.h"
#import <Simon/SIConstants.h>
#import <CocoaHTTPServer/HTTPDataResponse.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIHttpResponseBody.h>
#import <Simon/SIHttpRequestProcessor+Simon.h>

@implementation SIHttpHeartbeatRequestProcessor

-(BOOL) canProcessPath:(NSString *) path withMethod:(SIHttpMethod) method {
	return method == SIHttpMethodGet && [path isEqualToString:HTTP_PATH_HEARTBEAT];
}

-(NSObject<HTTPResponse> *) processPath:(NSString *) path withMethod:(SIHttpMethod) method andBody:(NSString *) body {

	// Post a success to the caller.
	SIHttpResponseBody *responseBody = [[[SIHttpResponseBody alloc] init] autorelease];
	responseBody.status = SIHttpStatusOk;
	return [self httpResponseWithBody:responseBody];
}

-(BOOL) expectingHttpBody {
	return NO;
}

@end
