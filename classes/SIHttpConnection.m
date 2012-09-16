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

-(void) sendRESTRequest:(NSString *) path
					  method:(SIHttpMethod) method
		responseBodyClass:(Class) responseBodyClass
			  successBlock:(RequestSentBlock) successBlock
				 errorBlock:(RequestSentErrorBlock) errorBlock {
	
	dispatch_async(_sendQ, ^{
		
		NSURL *url = [[[NSURL alloc] initWithScheme:@"http" host:_baseUrl path:path] autorelease];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
																				 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
																			timeoutInterval:HTTP_REQUEST_TIMEOUT];
		request.HTTPMethod = method == SIHttpMethodGet ? @"GET" : @"POST";
		
		NSError *error = nil;
		NSURLResponse *response = nil;
		DC_LOG(@"Sending %@", [url absoluteURL]);
		NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		DC_LOG(@"Sending %@, request response received", path);
		
		// Check for an error.
		if (data == nil) {
			NSString *msg = [error localizedErrorMessage];
			DC_LOG(@"Sending %@, error: %@", path, msg);
			dispatch_async(_replyQ, ^{
				errorBlock(nil, [NSString stringWithFormat:@"Sent %@ and received an error: %@", path, msg]);
			});
			return;
		}
		
		// Now analyse the response.
		
		// First de-serialise to a NSDictionary.
		id body = nil;
		if (responseBodyClass != nil) {
			id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
			if (jsonData == nil) {
				DC_LOG(@"Sending %@, error processing response body: %@", path, DC_DATA_TO_STRING(data));
				dispatch_async(_replyQ, ^{
					errorBlock(nil, [NSString stringWithFormat:@"Unexpected response: %@", DC_DATA_TO_STRING(data)]);
				});
				return;
			}
			
			// Convert the object to our expected type an call the response block.
			body = [[(id<SIJsonAware>)[responseBodyClass alloc] initWithJsonDictionary:jsonData] autorelease];
		}
		
		if (successBlock != NULL) {
			dispatch_async(_replyQ, ^{
				successBlock(body);
				DC_LOG(@"Sending %@, success", path);
			});
		}
	});
	
}

@end
