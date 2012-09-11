//
//  PieMan.m
//  Simon
//
//  Created by Derek Clarkson on 28/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "PIPieman.h"
#import "PIException.h"
#import <Simon/SIConstants.h>
#import <dUsefulStuff/DCCommon.h>
#import "PIHeartbeat.h"
#import "PISimulator.h"
#import <Simon/SICoreHttpSimpleResponseBody.h>
#import "SICoreHttpConnection.h"
#import <Simon/SICoreHttpIncomingConnection.h>
#import <CocoaHTTPServer/DDLog.h>
#import <CocoaHTTPServer/DDTTYLogger.h>
#import <CocoaHTTPServer/HTTPServer.h>

@interface PIPieman () {
@private
	PIHeartbeat *_heartbeat;
	PISimulator *_simulator;
	SICoreHttpConnection *_simon;
	HTTPServer *server;
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
	DC_DEALLOC(server);
	DC_DEALLOC(_heartbeat);
	DC_DEALLOC(_simulator);
	DC_DEALLOC(_simon);
	[super dealloc];
}

-(id) init {
	self = [super init];
	if (self) {
		
		_finished = NO;

		// Heartbeat
		_heartbeat = [[PIHeartbeat alloc] init];
		_heartbeat.delegate = self;
		
		// Get a custom port value from the process args.
		NSInteger port = self.piemanPort > 0 ? self.piemanPort : HTTP_PIEMAN_PORT;
		
		// Setup the request processors.
		//SICoreHttpRequestProcessor * runAllProcessor = [[[SIHttpRunAllRequestProcessor alloc] init] autorelease];
		[SICoreHttpIncomingConnection setProcessors:[NSArray arrayWithObjects: nil]];
		
		DC_LOG(@"Starting HTTP server on port: %li", port);
		[DDLog addLogger:[DDTTYLogger sharedInstance]];
		server = [[HTTPServer alloc] init];
		[server setConnectionClass:[SICoreHttpIncomingConnection class]];
		[server setPort:port];
		NSError *error = nil;
		if(![server start:&error]) {
			@throw [PIException exceptionWithReason:[NSString stringWithFormat:@"Error starting HTTP Server: %@", error]];
		}
		
		// Setup the comms.
		dispatch_queue_t simonsQ = dispatch_queue_create(SIMON_QUEUE_NAME, NULL);
		_simon = [[SICoreHttpConnection alloc] initWithHostUrl:[NSString stringWithFormat:@"%@:%i", HTTP_SIMON_HOST, HTTP_SIMON_PORT]
																sendGCDQueue:simonsQ
														  responseGCDQueue:dispatch_get_main_queue()];
		dispatch_release(simonsQ);
	}
	return self;
}

-(void) start {
	
	printf("Starting Simon test run\n");
	
	// Assemble arguments.
	DC_LOG(@"Assembling arguments");
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
	
	DC_LOG(@"Looking for currently running simulator before launching")
	[_simulator shutdownSimulator:^{
		DC_LOG(@"Starting launch procedure.");
		// Don't set delegate until here so we are not bugged with shutdown notifications.
		_simulator.delegate = self;
		[_simulator reset];
		[_heartbeat start];
		[_simulator launch];
	}];
	
}

#pragma mark - Tasks

-(void) sendRunAllRequest {
	[_simon sendRESTRequest:HTTP_PATH_RUN_ALL
			responseBodyClass:[SICoreHttpSimpleResponseBody class]
				  successBlock:NULL
					 errorBlock:^(id data, NSString *errorMsg){
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
