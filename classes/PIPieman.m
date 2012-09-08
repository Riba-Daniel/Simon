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
#import "PISimonComms.h"
#import <Simon/SICoreHttpResponseBody.h>

@interface PIPieman () {
@private
	PIHeartbeat *_heartbeat;
	PISimulator *_simulator;
	PISimonComms *_comms;
}

-(void) sendRunAllRequest;

@end

@implementation PIPieman

@synthesize finished = _finished;
@synthesize appPath = _appPath;
@synthesize piemanPort = _piemanPort;
@synthesize simonPort = _simonPort;
@synthesize appArgs = _appArgs;
@synthesize exitCode = _exitCode;

#pragma mark - Lifecycle

-(void) dealloc {
	self.appPath = nil;
	self.appArgs = nil;
	DC_DEALLOC(_heartbeat);
	DC_DEALLOC(_simulator);
	DC_DEALLOC(_comms);
	[super dealloc];
}

-(id) init {
	self = [super init];
	if (self) {
		_finished = NO;
		_heartbeat = [[PIHeartbeat alloc] init];
		_heartbeat.delegate = self;
		_comms = [[PISimonComms alloc] init];
		_comms.delegate = self;
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
	_simulator.args = args;
	
	[_simulator shutdownSimulator:^{
		// Don't set delegate until here so we are not bugged with shutdown notifications.
		_simulator.delegate = self;
		[_simulator reset];
		[_heartbeat start];
		[_simulator launch];
	}];
	
}

#pragma mark - Tasks

-(void) sendRunAllRequest {
	[_comms sendRESTRequest:HTTP_PATH_RUN_ALL
			responseBodyClass:[SICoreHttpResponseBody class]
			  onResponseBlock:^(id obj){}
				  onErrorBlock:^(id data, NSString *errorMsg){
					  printf("Error: %s", [errorMsg UTF8String]);
					  _exitCode = EXIT_FAILURE;
				  }];
}

#pragma mark - Delegate methods.

-(void) errorFromSimon {
	[_simulator shutdown];
	_exitCode = EXIT_FAILURE;
}

-(void) simulatorAppDidStart:(PISimulator *) simulator {
	DC_LOG(@"Simulator has started, sending run request");
	[self sendRunAllRequest];
}

-(void) heartbeatDidTimeout {
	DC_LOG(@"Heart beat timed out, asking simulator to quit.");
	[_simulator shutdown];
	_exitCode = EXIT_FAILURE;
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

@end
