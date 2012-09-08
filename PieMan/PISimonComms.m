//
//  PISimon.m
//  Simon
//
//  Created by Derek Clarkson on 8/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "PISimonComms.h"
#import "PIConstants.h"
#import <Simon/SIConstants.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIJsonAware.h>

@interface PISimonComms () {
@private
	dispatch_queue_t simonQueue;
}

-(void) executeOnSimonThread:(SimpleBlock) block;
-(void) executeOnPiemanThread:(SimpleBlock) block;

@end

@implementation PISimonComms

@synthesize delegate = _delegate;

-(void) dealloc {
	dispatch_release(simonQueue);
	[super dealloc];
}

-(id) init {
	self = [super init];
	if (self) {
		simonQueue = dispatch_queue_create(PI_SIMON_QUEUE_NAME, 0);
	}
	return self;
}

-(void) sendRESTRequest:(NSString *) path
		responseBodyClass:(Class) responseBodyClass
		  onResponseBlock:(ResponseBlock) responseBlock
			  onErrorBlock:(ResponseErrorBlock) responseErrorBlock {
	
	[self executeOnSimonThread:^{
		
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%i%@", HTTP_SIMON_PORT, path]];
		NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:SIMON_REQUEST_TIMEOUT];
		DC_LOG(@"Sending request %@", url);
		
		NSError *error = nil;
		NSURLResponse *response = nil;
		NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		
		// Check for an error.
		if (data == nil) {
			[self executeOnPiemanThread:^{
				responseErrorBlock(nil, [NSString stringWithFormat:@"Error: Sent %@ command to Simon and received no response.", path]);
			}];
			return;
		}
		
		// Now analyse the response.
		
		// First de-serialise to a NSDictionary.
		id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		if (jsonData == nil) {
			responseErrorBlock(nil, [NSString stringWithFormat:@"Error: Unexpected response from Simon: %@", DC_DATA_TO_STRING(data)]);
			return;
		}
		
		// Convert the object to our expected type an call the response block.
		id body = [[(id<SIJsonAware>)[responseBodyClass alloc] initWithJsonDictionary:jsonData] autorelease];
		[self executeOnPiemanThread:^{
			responseBlock(body);
		}];
	}];
	
}


-(void) executeOnSimonThread:(SimpleBlock) block {
	dispatch_async(simonQueue, ^{
		DC_LOG(@"Executing block on Simon's comms thread");
		block();
	});
}

-(void) executeOnPiemanThread:(SimpleBlock) block {
	dispatch_async(dispatch_get_main_queue(), ^{
		DC_LOG(@"Executing block on Simon's main thread");
		block();
	});
}

@end
