//
//  PieMan.m
//  Simon
//
//  Created by Derek Clarkson on 28/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "PIHeartbeat.h"
#import <Simon/SIConstants.h>
#import <dUsefulStuff/DCCommon.h>

// Pieman's background thread name.
#define PI_QUEUE_NAME "au.com.derekclarkson.pieman"
#define PI_HEARTBEAT_QUEUE_NAME "au.com.derekclarkson.pieman.heartbeat"

#define HEARTBEAT_FREQUENCY 2.0

@interface PIHeartbeat () {
@private
	int heartbeats;
	dispatch_queue_t heartbeatQueue;
}

-(void) heartbeat;
-(void) queueHeartbeat;
-(void) notifyDelegate:(SEL) selector;

@end

@implementation PIHeartbeat

@synthesize delegate = _delegate;

-(void) dealloc {
	dispatch_release(heartbeatQueue);
	[super dealloc];
}

-(id) init {
	self = [super init];
	if (self) {
		heartbeatQueue = dispatch_queue_create(PI_HEARTBEAT_QUEUE_NAME, 0);
	}
	return self;
}

-(void) start {
	[self notifyDelegate:@selector(heartbeatDidStart)];
	[self queueHeartbeat];
}

-(void) heartbeat {
	
	heartbeats++;
	
	// Query Simon
	NSError *error = nil;
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%i%@", HTTP_SIMON_PORT, HTTP_PATH_HEARTBEAT]];
	DC_LOG(@"Checking url %@", url);
	NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
	DC_LOG(@"Response %@", response);
	
	if (response == nil) {
		NSLog(@"Error: %@", [error localizedFailureReason]);
		[self notifyDelegate:@selector(heartbeatDidEnd)];
		return;
	}
	
	if (heartbeats > 4) {
		DC_LOG(@"Exiting heartbeats");
		[self notifyDelegate:@selector(heartbeatDidEnd)];
		return;
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
