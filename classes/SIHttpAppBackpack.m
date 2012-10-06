//
//  SIHttpBackpack.m
//  Simon
//
//  Created by Derek Clarkson on 9/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Simon/SIHttpAppBackpack.h>
#import <dUsefulStuff/DCCommon.h>
#import <dUsefulStuff/NSError+dUsefulStuff.h>
#import <CocoaHTTPServer/HTTPServer.h>
#import <CocoaHTTPServer/DDLog.h>
#import <CocoaHTTPServer/DDTTYLogger.h>
#import <Simon/SIServerException.h>
#import <Simon/SIHttpIncomingConnection.h>
#import <Simon/SIHttpPayload.h>
#import <Simon/SIHttpGetRequestHandler.h>
#import <Simon/SIHttpPostRequestHandler.h>
#import <Simon/SIHttpConnection.h>
#import <Simon/NSProcessInfo+Simon.h>
#import <Simon/SIJsonAware.h>
#import <SImon/SIHttpResultSender.h>

@interface SIHttpAppBackpack () {
@private
	SIHttpConnection *_pieman;
	dispatch_queue_t _piemanQ;
	int _sendCount;
	SIHttpResultSender *_resultSender;
}

-(void) sendReadyToPieman;

@end

@implementation SIHttpAppBackpack

@synthesize server = _server;

-(void) dealloc {

	DC_DEALLOC(_resultSender);

	DC_LOG(@"Stopping server");
	[_server stop];
	dispatch_release(_piemanQ);
	DC_DEALLOC(_pieman);
	DC_DEALLOC(_server);
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self) {
		
		// Get a custom port value from the process args.
		NSString *strValue = [[NSProcessInfo processInfo] argumentValueForName:ARG_SIMON_PORT];
		unsigned short intValue = (unsigned short)[strValue integerValue];
		unsigned short port = intValue > 0 ? intValue : HTTP_SIMON_PORT;
		
		// Setup the request processors.
		
		// Run all tests command. Note this will cause a retain on this instance.
		RequestReceivedBlock runAllBlock = ^(id<SIJsonAware> obj){
			
			// Send the notification to start processing.
			DC_LOG(@"Pieman has requested to run all tests");
			NSNotification *notification = [NSNotification notificationWithName:SI_RUN_STORIES_NOTIFICATION object:self];
			[[NSNotificationCenter defaultCenter] postNotification:notification];
			
			return [SIHttpPayload httpPayloadWithStatus:SIHttpStatusOk message:nil];
		};
		
		SIHttpPostRequestHandler * runAllProcessor = [[SIHttpPostRequestHandler alloc] initWithPath:HTTP_PATH_RUN_ALL
																											requestBodyClass:NULL
																														process:runAllBlock];
		
		// Simple heart beat response. 
		SIHttpGetRequestHandler * heartbeatProcessor = [[SIHttpGetRequestHandler alloc] initWithPath:HTTP_PATH_HEARTBEAT process:nil];

		// Exit app command. Note this will cause a retain on this instance.
		RequestReceivedBlock exitBlock = ^(id obj){
			// Queue an exit on the main thread.
			DC_LOG(@"Queuing exit command.");
			[[SIAppBackpack backpack] exit];
			
			SIHttpPayload *body = [[[SIHttpPayload alloc] init] autorelease];
			body.status = SIHttpStatusOk;
			return body;
		};
		
		SIHttpPostRequestHandler * exitProcessor = [[SIHttpPostRequestHandler alloc] initWithPath:HTTP_PATH_EXIT
																										 requestBodyClass:NULL
																													 process:exitBlock];
		
		[SIHttpIncomingConnection setProcessors:[NSArray arrayWithObjects:runAllProcessor, heartbeatProcessor, exitProcessor, nil]];
		[runAllProcessor release];
		[exitProcessor release];
		[heartbeatProcessor release];
		
		DC_LOG(@"Starting HTTP server on port: %i", port);
		[DDLog addLogger:[DDTTYLogger sharedInstance]];
		_server = [[HTTPServer alloc] init];
		[_server setConnectionClass:[SIHttpIncomingConnection class]];
		[_server setPort:port];
		NSError *error = nil;
		if(![_server start:&error]) {
			@throw [SIServerException exceptionWithReason:[NSString stringWithFormat:@"Error starting HTTP Server: %@", error]];
		}
		
		// Start up the Piemans connection.
		_piemanQ = dispatch_queue_create([PIEMAN_QUEUE_NAME UTF8String], NULL);
		_pieman = [[SIHttpConnection alloc] initWithHostUrl:[NSString stringWithFormat:@"%@:%i", HTTP_PIEMAN_HOST, HTTP_PIEMAN_PORT]
														  sendGCDQueue:_piemanQ
													 responseGCDQueue:self.queue];
		
		// init the result listener which tells the Pieman when things happen.
		_resultSender = [[SIHttpResultSender alloc] initWithConnection:_pieman];

	}
	return self;
}

-(void) startUp:(NSNotification *) notification {
	[super startUp:notification];
}

-(void) startUpFinished {
	_sendCount = 0;
	[self sendReadyToPieman];
}

-(void) sendReadyToPieman {
	// Tell the Pieman we are ready to rock.
	[_pieman sendRESTRequest:HTTP_PATH_SIMON_READY
						  method:SIHttpMethodPost
					requestBody:nil
			responseBodyClass:[SIHttpPayload class]
				  successBlock:NULL
					 errorBlock:^(id<SIJsonAware> obj, NSError *error){
						 
						 DC_LOG(@"Error returned attempting to contact the Pieman: %@", [error localizedErrorMessage]);
						 _sendCount++;
						 if (_sendCount >= HTTP_MAX_RETRIES) {
							 DC_LOG(@"Throwing exception");
							 @throw [SIServerException exceptionWithReason:[NSString stringWithFormat:@"Error received attempting to contact the Pieman: %@", [error localizedErrorMessage]]];
						 }
						 
						 DC_LOG(@"requeuing send ready request");
						 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, lround(HTTP_RETRY_INTERVAL * NSEC_PER_SEC));
						 dispatch_after(popTime, dispatch_get_current_queue(), ^(void){
							 [self sendReadyToPieman];
						 });
					 }];
}

-(void) shutDown:(NSNotification *) notification {
	[super shutDown:notification];
	// Clear static list of processors which are retaining this instance.
	DC_LOG(@"Clearing response processors");
	[SIHttpIncomingConnection setProcessors:nil];
}

-(void) runFinished:(NSNotification *) notification {
	[super runFinished:notification];
}

-(void) runStories:(NSNotification *) notification {
	[super runStories:notification];
}

@end
