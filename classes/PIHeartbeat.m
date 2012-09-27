//
//  PieMan.m
//  Simon
//
//  Created by Derek Clarkson on 28/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "PIHeartbeat.h"
#import <Simon/SICore.h>
#import <Simon/SIHttpPayload.h>
#import <dUsefulStuff/NSError+dUsefulStuff.h>
#import "PIConstants.h"
#import <dUsefulStuff/DCCommon.h>
#import "SIHttpConnection.h"

@interface PIHeartbeat () {
@private
	int heartbeats;
	BOOL shutdown;
	SIHttpConnection *_simon;
	
}

-(void) heartbeat;
-(void) notifyDelegate:(SEL) selector;

@end

@implementation PIHeartbeat

@synthesize delegate = _delegate;

-(void) dealloc {
	DC_LOG(@"Deallocing");
	DC_DEALLOC(_simon);
	[super dealloc];
}

-(void) start {
	
	DC_LOG(@"Starting heartbeat on it's own queue");
	[self notifyDelegate:@selector(heartbeatDidStart)];
	
	dispatch_queue_t simonsQ = dispatch_queue_create(SIMON_QUEUE_NAME, 0);
	dispatch_queue_t heartbeatQ = dispatch_queue_create(SIMON_HEARTBEAT_QUEUE_NAME, 0);
	
	_simon = [[SIHttpConnection alloc] initWithHostUrl:[NSString stringWithFormat:@"%@:%i", HTTP_SIMON_HOST, HTTP_SIMON_PORT]
															sendGCDQueue:simonsQ
													  responseGCDQueue:heartbeatQ];
	
	dispatch_async(heartbeatQ, ^(){
		shutdown = NO;
		[self heartbeat];
	});
	
	dispatch_release(simonsQ);
	dispatch_release(heartbeatQ);
	
}

-(void) stop {
	DC_LOG(@"Setting shutdown flag");
	shutdown = YES;
}

-(void) heartbeat {
	
	if (shutdown) {
		DC_LOG(@"Shutdown requested. Exiting heartbeat.");
		return;
	}
	
	// Query Simon
	SimpleBlock queueHeartbeat = ^{
		DC_LOG(@"Queuing heartbeat on queue: %s", dispatch_queue_get_label(dispatch_get_current_queue()));
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, HEARTBEAT_FREQUENCY * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_current_queue(), ^(void){
			[self heartbeat];
		});
	};
	
	[_simon sendRESTGetRequest:HTTP_PATH_HEARTBEAT
				responseBodyClass:[SIHttpPayload class]
				  successBlock:^(id<SIJsonAware> obj) {
					  
					  // Received a response.
					  DC_LOG(@"Heartbeat responsed");
					  heartbeats = 0;
					  // Requeue
					  queueHeartbeat();
					  
				  }
					 errorBlock:^(id<SIJsonAware> obj, NSError *error){
						 
						 // If there is an error, increment the count and try for 5 times before exiting.
						 heartbeats++;
						 DC_LOG(@"Heartbeat failed to respond: attempt %i, %@", heartbeats, [error localizedErrorMessage]);
						 if (heartbeats >= HEARTBEAT_MAX_ATTEMPTS) {
							 [self notifyDelegate:@selector(heartbeatDidTimeout)];
							 DC_LOG(@"Exiting heartbeats");
							 return;
						 }
						 
						 // Requeue
						 queueHeartbeat();
						 
					 }];
	
}

-(void) notifyDelegate:(SEL) selector {
	if (self.delegate != nil) {
		if ([self.delegate respondsToSelector:selector]) {
			[self.delegate performSelectorOnMainThread:selector withObject:self waitUntilDone:NO];
		}
	}
}

@end
