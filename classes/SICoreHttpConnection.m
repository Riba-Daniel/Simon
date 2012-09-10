//
//  SICoreHttpConnection.m
//  Simon
//
//  Created by Derek Clarkson on 9/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SICoreHttpConnection.h"
#import <Simon/SICore.h>
#import <Simon/SIJsonAware.h>
#import <dUsefulStuff/DCCommon.h>

@interface SICoreHttpConnection () {
@private
	dispatch_queue_t _sendQ;
	dispatch_queue_t _replyQ;
	NSString *_baseUrl;
}

@end

@implementation SICoreHttpConnection

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
		responseBodyClass:(Class) responseBodyClass
			  successBlock:(ResponseBlock) successBlock
				 errorBlock:(ResponseErrorBlock) errorBlock {
	
	dispatch_async(_sendQ, ^{
		
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _baseUrl, path]];
		NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:HTTP_REQUEST_TIMEOUT];
		DC_LOG(@"Sending request %@", url);
		
		NSError *error = nil;
		NSURLResponse *response = nil;
		NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		
		// Check for an error.
		if (data == nil) {
			dispatch_async(_replyQ, ^{
				errorBlock(nil, [NSString stringWithFormat:@"Error: Sent %@ command to Simon and received no response.", path]);
			});
			return;
		}
		
		// Now analyse the response.
		
		// First de-serialise to a NSDictionary.
		id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		if (jsonData == nil) {
			dispatch_async(_replyQ, ^{
				errorBlock(nil, [NSString stringWithFormat:@"Error: Unexpected response from Simon: %@", DC_DATA_TO_STRING(data)]);
			});
			return;
		}
		
		// Convert the object to our expected type an call the response block.
		id body = [[(id<SIJsonAware>)[responseBodyClass alloc] initWithJsonDictionary:jsonData] autorelease];
		dispatch_async(_replyQ, ^{
			successBlock(body);
		});
	});
	
}

@end
