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

@implementation SIHttpHeartbeatRequestProcessor

-(BOOL) canProcessPath:(NSString *) path withMethod:(SIHttpMethod) method {
	return method == SIHttpMethodGet && [path isEqualToString:HTTP_PATH_HEARTBEAT];
}

-(NSObject<HTTPResponse> *) processPath:(NSString *) path withMethod:(SIHttpMethod) method andBody:(NSString *) body {
	NSString *response = [NSString stringWithFormat:HTTP_STATUS_RESPONSE, DC_PRETTY_BOOL(YES)];
	return [[[HTTPDataResponse alloc] initWithData:DC_STRING_TO_DATA(response)] autorelease];
}

-(BOOL) expectingHttpBody {
	return NO;
}

@end
