//
//  PieMan.m
//  Simon
//
//  Created by Derek Clarkson on 28/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "PIHeartbeat.h"
#import "PIConstants.h"
#import <Simon/SIConstants.h>
#import <dUsefulStuff/DCCommon.h>

@interface PIHeartbeat () {
@private
	int heartbeats;
	dispatch_queue_t heartbeatQueue;
	BOOL shutdown;
	NSURLRequest *request;
}

-(void) heartbeat;
-(void) queueHeartbeat;
-(void) notifyDelegate:(SEL) selector;

@end

@implementation PIHeartbeat

@synthesize delegate = _delegate;

-(void) dealloc {
	DC_DEALLOC(request);
	dispatch_release(heartbeatQueue);
	[super dealloc];
}

-(id) init {
	self = [super init];
	if (self) {
		heartbeatQueue = dispatch_queue_create(PI_HEARTBEAT_QUEUE_NAME, 0);
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%i%@", HTTP_SIMON_PORT, HTTP_PATH_HEARTBEAT]];
		
		request = [[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:HEARTBEAT_TIMEOUT] retain];
		DC_LOG(@"Checking url %@", request.URL);

		shutdown = NO;
	}
	return self;
}

-(void) start {
	DC_LOG(@"Starting heartbeat");
	[self notifyDelegate:@selector(heartbeatDidStart)];
	[self queueHeartbeat];
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
	NSError *error = nil;
	NSURLResponse *response = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if (data == nil) {
		DC_LOG(@"Heartbeat failed at attempt %i", heartbeats);
		heartbeats++;
		if (heartbeats >= HEARTBEAT_MAX_ATTEMPTS) {
			[self notifyDelegate:@selector(heartbeatDidTimeout)];
			DC_LOG(@"Exiting heartbeats");
			return;
		}
	} else {
		// Reset the heartbeat count.
		DC_LOG(@"Heartbeat response %@", DC_DATA_TO_STRING(data));
		heartbeats = 0;
	}
	
	// Requeue
	[self queueHeartbeat];
	
}

-(void) notifyDelegate:(SEL) selector {
	if (self.delegate != nil) {
		if ([self.delegate respondsToSelector:selector]) {
			[self.delegate performSelectorOnMainThread:selector withObject:self waitUntilDone:NO];
		}
	}
}

-(void) queueHeartbeat {
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, HEARTBEAT_FREQUENCY * NSEC_PER_SEC);
	dispatch_after(popTime, heartbeatQueue, ^(void){
		[NSThread currentThread].name = @"Simon heartbeat check";
		[self heartbeat];
	});
}

@end
