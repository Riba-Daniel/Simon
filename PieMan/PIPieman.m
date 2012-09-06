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
	PIHeartbeat *_heartbeat;
	PISimulator *_simulator;
	
}

-(void) executeOnPieManThread:(void (^)()) block;

@end

@implementation PIPieman

@synthesize finished = _finished;
@synthesize appPath = _appPath;
@synthesize piemanPort = _piemanPort;
@synthesize simonPort = _simonPort;
@synthesize appArgs = _appArgs;

-(void) dealloc {
	self.appPath = nil;
	self.appArgs = nil;
	dispatch_release(queue);
	DC_DEALLOC(_heartbeat);
	DC_DEALLOC(_simulator);
	[super dealloc];
}

-(id) init {
	self = [super init];
	if (self) {
		_finished = NO;
		queue = dispatch_queue_create(PI_QUEUE_NAME, 0);
		_heartbeat = [[PIHeartbeat alloc] init];
		_heartbeat.delegate = self;
	}
	return self;
}

-(void) start {
	
	// Assemble arguments.
	NSMutableArray *args = [NSMutableArray array];

	if (self.piemanPort > 0 && self.piemanPort != HTTP_PIEMAN_PORT) {
		[args addObject:ARG_PIEMAN_PORT];
		[args addObject:[NSString stringWithFormat:@"%li", self.piemanPort]];
	}

	if (self.simonPort > 0 && self.simonPort != HTTP_SIMON_PORT) {
		[args addObject:ARG_SIMON_PORT];
		[args addObject:[NSString stringWithFormat:@"%li", self.simonPort]];
	}
	
	// Append args for the app.
	[args addObjectsFromArray:self.appArgs];

	_simulator = [[PISimulator alloc] initWithApplicationPath:self.appPath];
	_simulator.delegate = self;
	_simulator.args = args;

	// Start the simulator
	[_simulator launch];

	// Start the heartbeat to monitor the simulator.
	[_heartbeat start];

}

#pragma mark - Delegate methods.

-(void) heartbeatDidEnd {
	DC_LOG(@"Heart beat ended");
}

-(void) heartbeatDidTimeout {
	DC_LOG(@"Heart beat timed out, asking simulator to quit.");
	[_simulator shutdown];
}

-(void) simulatorDidStart:(PISimulator *) simulator {
	DC_LOG(@"Simulator started");
}

-(void) simulatorDidEnd:(PISimulator *) simulator {
	DC_LOG(@"Simulator ended, setting finished flag.");
	// If the simulator has shutdown then shutdown this program.
	_finished = YES;

	DC_LOG(@"Stopping heatbeat");
	[_heartbeat stop];
	
	// Trigger the run loop processing.
	CFRunLoopStop(CFRunLoopGetMain());
}

-(void) simulatorAppDidStart:(PISimulator *) simulator {
	DC_LOG(@"Simulator session started");
}

-(void) simulator:(PISimulator *) simulator appDidEndWithError:(NSError *) error {
	DC_LOG(@"Simulator session ended with error code: %li", [error code]);
}

-(void) simulator:(PISimulator *) simulator appDidFailToStartWithError:(NSError *) error {
	DC_LOG(@"Simulator session failed to start: %@", error);
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
