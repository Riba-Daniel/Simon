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
#import <Simon/SIHttpGetRequestHandler.h>
#import <Simon/SIHttpPostRequestHandler.h>
#import <Simon/SIHttpPayload.h>
#import "SIHttpConnection.h"
#import <Simon/SIHttpIncomingConnection.h>
#import <dUsefulStuff/NSError+dUsefulStuff.h>
#import <CocoaHTTPServer/DDLog.h>
#import <CocoaHTTPServer/DDTTYLogger.h>
#import <CocoaHTTPServer/HTTPServer.h>
#import <Simon/SIFinalReport.h>

@interface PIPieman () {
@private
	PIHeartbeat *_heartbeat;
	PISimulator *_simulator;
	SIHttpConnection *_simon;
	HTTPServer *server;
	int sendCount;
}

-(void) sendRunAllRequest;
-(SIHttpPostRequestHandler *) simonReadyHandler;
-(SIHttpPostRequestHandler *) simonFinishedHandler;

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
	
	// Clear the static list of http processors.
	[SIHttpIncomingConnection setProcessors:nil];
	
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
		[SIHttpIncomingConnection setProcessors:@[[self simonReadyHandler], [self simonFinishedHandler]]];
		
		// Setup the outgoing comms.
		dispatch_queue_t simonsQ = dispatch_queue_create(SIMON_QUEUE_NAME, NULL);
		_simon = [[SIHttpConnection alloc] initWithHostUrl:[NSString stringWithFormat:@"%@:%i", HTTP_SIMON_HOST, HTTP_SIMON_PORT]
														  sendGCDQueue:simonsQ
													 responseGCDQueue:dispatch_get_main_queue()];
		
		dispatch_async(simonsQ, ^{
			DC_LOG(@"Starting HTTP server on port: %li", port);
			[DDLog addLogger:[DDTTYLogger sharedInstance]];
			server = [[HTTPServer alloc] init];
			[server setConnectionClass:[SIHttpIncomingConnection class]];
			[server setPort:(unsigned short)port];
			NSError *error = nil;
			if(![server start:&error]) {
				@throw [PIException exceptionWithReason:[NSString stringWithFormat:@"Error starting HTTP Server: %@", error]];
			}
		});
		
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
	
	[_simon sendRESTPostRequest:HTTP_PATH_RUN_ALL
						 requestBody:nil
				 responseBodyClass:[SIHttpPayload class]
						successBlock:NULL
						  errorBlock:^(id data, NSError *error){
							  sendCount++;
							  if (sendCount < HTTP_MAX_RETRIES) {
								  DC_LOG(@"Requeuing run all request");
								  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, lround(HTTP_RETRY_INTERVAL * NSEC_PER_SEC));
								  dispatch_after(popTime, dispatch_get_current_queue(), ^(void){
									  [self sendRunAllRequest];
								  });
							  } else {
								  printf("Error: %s\n", [[error localizedErrorMessage] UTF8String]);
								  _exitCode = EXIT_FAILURE;
							  }
						  }];
}

-(SIHttpPostRequestHandler *) simonReadyHandler {
	RequestReceivedBlock simonReady = ^(id obj) {
		DC_LOG(@"Simon ready received, sending Run All request back to Simon");
		sendCount = 0;
		[self sendRunAllRequest];
		SIHttpPayload *body = [[[SIHttpPayload alloc] init] autorelease];
		body.status = SIHttpStatusOk;
		return body;
	};
	return [[[SIHttpPostRequestHandler alloc] initWithPath:HTTP_PATH_SIMON_READY
													  requestBodyClass:NULL
																  process:simonReady] autorelease];
}

-(SIHttpPostRequestHandler *) simonFinishedHandler {
	RequestReceivedBlock simonFinished = ^(id obj) {
		DC_LOG(@"Simon has finished running tests.");
		SIFinalReport *report = (SIFinalReport *) obj;
		if (report.failed > 0) {
			DC_LOG(@"Error: %lu failed tests", report.failed);
		}
		
		// Report to the command line.
		printf("\nTest report\n");
		printf("=====================================================\n");
		printf("Successful stories           : %lu\n", report.successful);
		printf("Failed stories               : %lu\n", report.failed);
		printf("Stories with missing mappings: %lu\n", report.notMapped);
		printf("Ignored stories              : %lu\n", report.ignored);
		printf("Stories not run              : %lu\n", report.notRun);
		
		// Queue the shutdown process.
		[_simulator shutdown];
		_exitCode = report.failed > 0 ? EXIT_FAILURE : EXIT_SUCCESS;
		
		// Say ok.
		SIHttpPayload *body = [[[SIHttpPayload alloc] init] autorelease];
		body.status = SIHttpStatusOk;
		return body;
	};
	return [[[SIHttpPostRequestHandler alloc] initWithPath:HTTP_PATH_RUN_FINISHED
													  requestBodyClass:[SIFinalReport class]
																  process:simonFinished] autorelease];
	
}

#pragma mark - Delegate methods.

-(void) messageReceivedOnPath:(NSString *) path withBody:(id) obj {
	DC_LOG(@"Simon ready, sending run request");
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
