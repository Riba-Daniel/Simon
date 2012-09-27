//
//  SICoreHttpConnection.m
//  Simon
//
//  Created by Derek Clarkson on 9/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIHttpConnection.h"
#import <Simon/SICore.h>
#import <Simon/SIJsonAware.h>
#import <dUsefulStuff/DCCommon.h>
#import <dUsefulStuff/NSError+dUsefulStuff.h>
#import <Simon/NSData+Simon.h>

@interface SIHttpConnection () {
@private
	dispatch_queue_t _sendQ;
	dispatch_queue_t _replyQ;
	NSString *_baseUrl;
}

@end

@implementation SIHttpConnection

-(void) dealloc {
	DC_DEALLOC(_baseUrl);
	dispatch_release(_sendQ);
	dispatch_release(_replyQ);
	[super dealloc];
}

-(id) initWithHostUrl:(NSString *) url
			sendGCDQueue:(dispatch_queue_t) sendQ
	  responseGCDQueue:(dispatch_queue_t) replyQ {
	self = [super init];
	if (self) {
		_baseUrl = [url retain];
		_sendQ = sendQ;
		dispatch_retain(_sendQ);
		_replyQ = replyQ;
		dispatch_retain(_replyQ);
	}
	return self;
}

-(void) sendRESTGetRequest:(NSString *) path
			responseBodyClass:(Class) responseBodyClass
				  successBlock:(RequestSentBlock) successBlock
					 errorBlock:(RequestSentErrorBlock) errorBlock {
	[self sendRESTRequest:path
						method:SIHttpMethodGet
				 requestBody:nil
		 responseBodyClass:responseBodyClass
				successBlock:successBlock
				  errorBlock:errorBlock];
}

-(void) sendRESTPostRequest:(NSString *) path
					 requestBody:(id<SIJsonAware>)requestBody
			 responseBodyClass:(Class) responseBodyClass
					successBlock:(RequestSentBlock) successBlock
					  errorBlock:(RequestSentErrorBlock) errorBlock {
	[self sendRESTRequest:path
						method:SIHttpMethodPost
				 requestBody:requestBody
		 responseBodyClass:responseBodyClass
				successBlock:successBlock
				  errorBlock:errorBlock];
}

-(void) sendRESTRequest:(NSString *) path
					  method:(SIHttpMethod) method
				requestBody:(id<SIJsonAware>)requestBody
		responseBodyClass:(Class) responseBodyClass
			  successBlock:(RequestSentBlock) successBlock
				 errorBlock:(RequestSentErrorBlock) errorBlock {
	
	dispatch_async(_sendQ, ^{
		
		NSError *error = nil;
		
		// Attempt to serialise the body.
		NSData *body = nil;
		if (requestBody != nil) {
			body = [NSJSONSerialization dataWithJSONObject:[requestBody jsonDictionary] options:0 error:&error];
			if (body == nil) {
				DC_LOG(@"Sending %@, rrror serialising request body: %@", path, error);
				dispatch_async(_replyQ, ^{
					errorBlock(nil, error);
				});
				return;
			}
			DC_LOG(@"Sending %@, post body %@", path, DC_DATA_TO_STRING(body));
		}
		
		// Setup the request.
		NSURL *url = [[[NSURL alloc] initWithScheme:@"http" host:_baseUrl path:path] autorelease];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
																				 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
																			timeoutInterval:HTTP_REQUEST_TIMEOUT];
		request.HTTPMethod = method == SIHttpMethodGet ? @"GET" : @"POST";
		[request setHTTPBody:body];
		
		NSURLResponse *response = nil;
		DC_LOG(@"Sending %@", [url absoluteURL]);
		NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		
		// Check for an error.
		if (data == nil) {
			DC_LOG(@"Sending %@, error: %@", path, [error localizedErrorMessage]);
			dispatch_async(_replyQ, ^{
				errorBlock(nil, error);
			});
			return;
		}
		
		// Now analyse the response.
		DC_LOG(@"Response body: %@", DC_DATA_TO_STRING(data));
		
		// First de-serialise to a NSDictionary.
		id<SIJsonAware> responseBody = nil;
		if (responseBodyClass != nil) {
			responseBody = [data jsonToObjectWithClass:responseBodyClass error:&error];
			if (responseBody == nil) {
				DC_LOG(@"Sending %@, error processing response body: %@", path, error);
				dispatch_async(_replyQ, ^{
					errorBlock(nil, error);
				});
				return;
			}
		}
		
		if (successBlock != NULL) {
			dispatch_async(_replyQ, ^{
				successBlock(responseBody);
				DC_LOG(@"Sending %@, success", path);
			});
		}
	});
	
}

@end
