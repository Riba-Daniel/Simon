//
//  PieMan.m
//  Simon
//
//  Created by Derek Clarkson on 28/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "PIPieman.h"
#import <Simon/SIConstants.h>
#import <dUsefulStuff/DCCommon.h>
#import "PIHeartbeat.h"
#import "PISimulator.h"

// Pieman's background thread name.
#define PI_QUEUE_NAME "au.com.derekclarkson.pieman"

@interface PIPieman () {
@private
	dispatch_queue_t queue;
	PIHeartbeat *heartbeat;
	PISimulator *simulator;
	
}

-(void) executeOnPieManThread:(void (^)()) block;

@end

@implementation PIPieman

@synthesize finished = _finished;

-(void) dealloc {
	dispatch_release(queue);
	DC_DEALLOC(heartbeat);
	DC_DEALLOC(simulator);
	[super dealloc];
}

-(id) init {
	self = [super init];
	if (self) {
		_finished = NO;
		queue = dispatch_queue_create(PI_QUEUE_NAME, 0);
		heartbeat = [[PIHeartbeat alloc] init];
		heartbeat.delegate = self;
	}
	return self;
}

-(void) start {
	
	DC_LOG(@"Launching app at path %@", self.appPath);

	[heartbeat start];
	
	// Start the simulator.
	simulator = [[PISimulator alloc] initWithApplicationPath:self.appPath];
	[simulator launch];
}

#pragma mark - Delegate methods.

-(void) heartbeatDidEnd {
	DC_LOG(@"Heart beat ended, asking simulator to quit.");
	[simulator shutdown];
	_finished = YES;
}

#pragma mark - Thread methods

-(void) executeOnPieManThread:(void (^)()) block {
	dispatch_async(queue, ^{
		DC_LOG(@"Executing block on Simon's background thread");
		[NSThread currentThread].name = @"Pieman";
		block();
	});
}

@end
