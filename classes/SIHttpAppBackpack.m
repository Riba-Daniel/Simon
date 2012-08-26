//
//  SIHttpBackpack.m
//  Simon
//
//  Created by Derek Clarkson on 9/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SIHttpAppBackpack.h>
#import <dUsefulStuff/DCCommon.h>
#import <CocoaHTTPServer/DDLog.h>
#import <CocoaHTTPServer/DDTTYLogger.h>
#import <Simon/SIServerException.h>
#import <Simon/SIIncomingHttpConnection.h>

@implementation SIHttpAppBackpack

-(void) dealloc {
	DC_LOG(@"Stopping server");
	[server stop];
	DC_DEALLOC(server);
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self) {
		
		// Get a custom port value from the process args.
		NSString *strValue = [SIAppBackpack argumentValueForName:ARG_SIMON_PORT];
		NSInteger intValue = [strValue integerValue];
		NSInteger port = intValue > 0 ? intValue : HTTP_SIMON_PORT;
		
		DC_LOG(@"Starting HTTP server on port: %i", port);
		[DDLog addLogger:[DDTTYLogger sharedInstance]];
		server = [[HTTPServer alloc] init];
		[server setConnectionClass:[SIIncomingHttpConnection class]];
		[server setPort:port];
		NSError *error = nil;
		if(![server start:&error])
		{
			@throw [SIServerException exceptionWithReason:[NSString stringWithFormat:@"Error starting HTTP Server: %@", error]];
		}
	}
	return self;
}

-(void) startUp:(NSNotification *) notification {
	[super startUp:notification];
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
