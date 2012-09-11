//
//  SIHttpBackpack.m
//  Simon
//
//  Created by Derek Clarkson on 9/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Simon/SIHttpAppBackpack.h>
#import <dUsefulStuff/DCCommon.h>
#import <CocoaHTTPServer/HTTPServer.h>
#import <CocoaHTTPServer/DDLog.h>
#import <CocoaHTTPServer/DDTTYLogger.h>
#import <Simon/SIServerException.h>
#import <Simon/SICoreHttpIncomingConnection.h>
#import <Simon/SICoreHttpSimpleResponseBody.h>
#import <Simon/SICoreHttpRequestProcessor.h>
#import <Simon/SIHttpRunAllRequestProcessor.h>
#import <Simon/SIHttpHeartbeatRequestProcessor.h>
#import <Simon/SIHttpExitRequestProcessor.h>
#import <Simon/SICoreHttpConnection.h>
#import <Simon/NSProcessInfo+Simon.h>

@interface SIHttpAppBackpack () {
@private
	SICoreHttpConnection *pieman;
	dispatch_queue_t piemanQ;
	int piemanSendResendRetryCount;
}

-(void) sendReadyToPieman;

@end

@implementation SIHttpAppBackpack

@synthesize server = _server;

-(void) dealloc {
	DC_LOG(@"Stopping server");
	[_server stop];
	dispatch_release(piemanQ);
	DC_DEALLOC(pieman);
	DC_DEALLOC(_server);
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self) {
		
		// Get a custom port value from the process args.
		NSString *strValue = [[NSProcessInfo processInfo] argumentValueForName:ARG_SIMON_PORT];
		NSInteger intValue = [strValue integerValue];
		NSInteger port = intValue > 0 ? intValue : HTTP_SIMON_PORT;

		// Setup the request processors.
		SICoreHttpRequestProcessor * runAllProcessor = [[[SIHttpRunAllRequestProcessor alloc] init] autorelease];
		SICoreHttpRequestProcessor * heartbeatProcessor = [[[SIHttpHeartbeatRequestProcessor alloc] init] autorelease];
		SICoreHttpRequestProcessor * exitProcessor = [[[SIHttpExitRequestProcessor alloc] init] autorelease];
		[SICoreHttpIncomingConnection setProcessors:[NSArray arrayWithObjects:runAllProcessor, heartbeatProcessor, exitProcessor, nil]];
		
		DC_LOG(@"Starting HTTP server on port: %i", port);
		[DDLog addLogger:[DDTTYLogger sharedInstance]];
		_server = [[HTTPServer alloc] init];
		[_server setConnectionClass:[SICoreHttpIncomingConnection class]];
		[_server setPort:port];
		NSError *error = nil;
		if(![_server start:&error]) {
			@throw [SIServerException exceptionWithReason:[NSString stringWithFormat:@"Error starting HTTP Server: %@", error]];
		}
		
		// Start up the Piemans connection.
		piemanQ = dispatch_queue_create(PIEMAN_QUEUE_NAME, NULL);
		pieman = [[SICoreHttpConnection alloc] initWithHostUrl:[NSString stringWithFormat:@"%@:%i", HTTP_PIEMAN_HOST, HTTP_PIEMAN_PORT]
																sendGCDQueue:piemanQ
														  responseGCDQueue:self.queue];
	}
	return self;
}

-(void) startUp:(NSNotification *) notification {
	[super startUp:notification];
	[self sendReadyToPieman];
}

-(void) sendReadyToPieman {
	// Tell the Pieman we are ready to rock.
	[pieman sendRESTRequest:HTTP_PATH_SIMON_READY
			responseBodyClass:[SICoreHttpSimpleResponseBody class]
				  successBlock:NULL
					 errorBlock:^(id obj, NSString *errorMsg){
						 
						 DC_LOG(@"Error returned attempting to contact the Pieman.");
						 piemanSendResendRetryCount++;
						 if (piemanSendResendRetryCount >= SEND_READY_MAX_RETRIES) {
							 @throw [SIServerException exceptionWithReason:[NSString stringWithFormat:@"Error received attempting to contact the Pieman: %@", errorMsg]];
						 }
						 
						 DC_LOG(@"requeuing send ready request");
						 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, SEND_READY_RETRY_INTERVAL * NSEC_PER_SEC);
						 dispatch_after(popTime, dispatch_get_current_queue(), ^(void){
							 [self sendReadyToPieman];
						 });
					 }];
}

-(void) shutDown:(NSNotification *) notification {
	[super shutDown:notification];
}

-(void) runFinished:(NSNotification *) notification {
	[super runFinished:notification];
}

-(void) runStories:(NSNotification *) notification {
	[super runStories:notification];
}

@end
