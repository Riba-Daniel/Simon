//
//  SIHttpExitRequestProcessor.m
//  Simon
//
//  Created by Derek Clarkson on 27/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIHttpExitRequestProcessor.h"
#import <Simon/SIConstants.h>
#import <CocoaHTTPServer/HTTPDataResponse.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIAppBackpack.h>

@implementation SIHttpExitRequestProcessor

-(BOOL) canProcessPath:(NSString *) path withMethod:(SIHttpMethod) method {
	return method == SIHttpMethodPost && [path isEqualToString:HTTP_PATH_EXIT];
}

-(NSObject<HTTPResponse> *) processPath:(NSString *) path withMethod:(SIHttpMethod) method andBody:(NSString *) body {

	// Queue an exit on the main thread.
	DC_LOG(@"Queuing exit command.");
	[[SIAppBackpack backpack] exit];

	// Post a success to the caller.
	NSString *response = [NSString stringWithFormat:HTTP_STATUS_RESPONSE, DC_PRETTY_BOOL(YES)];
	return [[[HTTPDataResponse alloc] initWithData:DC_STRING_TO_DATA(response)] autorelease];
}

-(BOOL) expectingHttpBody {
	return NO;
}



@end
