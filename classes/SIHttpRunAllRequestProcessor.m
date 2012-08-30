//
//  SIHttpRunAllRequest.m
//  Simon
//
//  Created by Derek Clarkson on 24/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SIHttpRunAllRequestProcessor.h>
#import <Simon/SIConstants.h>
#import <CocoaHTTPServer/HTTPDataResponse.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIHttpResponseBody.h>
#import <Simon/SIHttpRequestProcessor+Simon.h>

@implementation SIHttpRunAllRequestProcessor

-(BOOL) canProcessPath:(NSString *) path withMethod:(SIHttpMethod) method {
	return method == SIHttpMethodPost && [path isEqualToString:HTTP_PATH_RUN_ALL];
}

-(NSObject<HTTPResponse> *) processPath:(NSString *) path withMethod:(SIHttpMethod) method andBody:(NSString *) body {
	
	// Send the notification to start processing.
	NSNotification *notification = [NSNotification notificationWithName:SI_RUN_STORIES_NOTIFICATION object:self];
	[[NSNotificationCenter defaultCenter] postNotification:notification];

	// Post a success to the caller.
	SIHttpResponseBody *responseBody = [[[SIHttpResponseBody alloc] init] autorelease];
	responseBody.status = SIHttpStatusOk;
	return [self httpResponseWithBody:responseBody];

}

-(BOOL) expectingHttpBody {
	return NO;
}

@end
