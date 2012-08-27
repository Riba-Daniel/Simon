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

@implementation SIHttpRunAllRequestProcessor

-(BOOL) canProcessPath:(NSString *) path withMethod:(SIHttpMethod) method {
	return method == SIHttpMethodPost && [path isEqualToString:HTTP_PATH_RUN_ALL];
}

-(NSObject<HTTPResponse> *) processPath:(NSString *) path withMethod:(SIHttpMethod) method andBody:(NSString *) body {
	NSNotification *notification = [NSNotification notificationWithName:SI_RUN_STORIES_NOTIFICATION object:self];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
	NSString *response = [NSString stringWithFormat:HTTP_STATUS_RESPONSE, DC_PRETTY_BOOL(YES)];
	return [[[HTTPDataResponse alloc] initWithData:DC_STRING_TO_DATA(response)] autorelease];
}

-(BOOL) expectingHttpBody {
	return NO;
}

@end
