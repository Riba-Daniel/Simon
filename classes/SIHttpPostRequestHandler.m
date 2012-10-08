//
//  SIHttpPostRequestHandler.m
//  Simon
//
//  Created by Derek Clarkson on 16/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIHttpPostRequestHandler.h"
#import <Simon/SIHttpPayload.h>
#import <Simon/NSData+Simon.h>
#import <Simon/SIHttpGetRequestHandler+Simon.h>

#import <dUsefulStuff/NSError+dUsefulStuff.h>
#import <dUsefulStuff/DCCommon.h>

@interface SIHttpPostRequestHandler () {
@private
	Class _requestBodyClass;
}

@end

@implementation SIHttpPostRequestHandler

#pragma mark - Lifecycle

-(id) initWithPath:(NSString *) path
  requestBodyClass:(Class) requestBodyClass
			  process:(RequestReceivedBlock) requestReceivedBlock {
	self = [super initWithPath:path process: requestReceivedBlock];
	if (self) {
		_requestBodyClass = requestBodyClass;
	}
	return self;
}

#pragma mark - Interface methods

-(BOOL) canProcessPath:(NSString *) path withMethod:(SIHttpMethod) method {
	return method == SIHttpMethodPost && [path isEqualToString:self.path];
}

-(BOOL) expectingHttpBody {
	return _requestBodyClass != NULL;
}

-(NSObject<HTTPResponse> *) processPath:(NSString *) path andBody:(NSData *) body {
	DC_LOG(@"Request %@, returning response", path);
	
	// Process the payload.
	id<SIJsonAware> requestPayload = nil;
	if ([self expectingHttpBody]) {
		NSError *error = nil;
		requestPayload = [body jsonToObjectWithClass:_requestBodyClass error:&error];
		if (requestPayload == nil) {
			DC_LOG(@"Error accessing request body: %@", [error localizedErrorMessage]);
			return [self httpResponseWithError:error];
		}
	}

	// Now process the request.
	id<SIJsonAware> responsePayload = [self runProcessWithRequestPayload:requestPayload];
	return [self httpResponseWithPayload:responsePayload];
}

@end
