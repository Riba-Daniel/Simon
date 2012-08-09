//
//  SIHttpBackpack.m
//  Simon
//
//  Created by Derek Clarkson on 9/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIHttpAppBackpack.h"
#import <dUsefulStuff/DCCommon.h>
#import <CocoaHTTPServer/DDLog.h>
#import <CocoaHTTPServer/DDTTYLogger.h>
#import "SIServerException.h"
#import "SIIncomingHTTPConnection.h"

@implementation SIHttpAppBackpack

-(void) dealloc {
	DC_LOG(@"Freeing memory and exiting");
	[server stop];
	DC_DEALLOC(server);
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self) {
		DC_LOG(@"Starting HTTP server");
		[DDLog addLogger:[DDTTYLogger sharedInstance]];
		server = [[HTTPServer alloc] init];
		[server setConnectionClass:[SIIncomingHTTPConnection class]];
		[server setPort:5678];
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
