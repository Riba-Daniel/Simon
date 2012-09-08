//
//  SIHttpExitRequestProcessor.m
//  Simon
//
//  Created by Derek Clarkson on 27/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "SIHttpExitRequestProcessor.h"
#import <Simon/SIConstants.h>
#import <CocoaHTTPServer/HTTPDataResponse.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIAppBackpack.h>
#import <Simon/SIHttpRequestProcessor+Simon.h>
#import <Simon/SICoreHttpResponseBody.h>

@implementation SIHttpExitRequestProcessor

-(BOOL) canProcessPath:(NSString *) path withMethod:(SIHttpMethod) method {
	return method == SIHttpMethodPost && [path isEqualToString:HTTP_PATH_EXIT];
}

-(NSObject<HTTPResponse> *) processPath:(NSString *) path withMethod:(SIHttpMethod) method andBody:(NSString *) body {

	// Queue an exit on the main thread.
	DC_LOG(@"Queuing exit command.");
	[[SIAppBackpack backpack] exit];

	// Post a success to the caller.
	SICoreHttpResponseBody *responseBody = [[[SICoreHttpResponseBody alloc] init] autorelease];
	responseBody.status = SIHttpStatusOk;
	return [self httpResponseWithBody:responseBody];
}

-(BOOL) expectingHttpBody {
	return NO;
}



@end
