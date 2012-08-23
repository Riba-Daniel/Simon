//
//  SIHttpAppBackpackTests.m
//  Simon
//
//  Created by Derek Clarkson on 5/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <OCMock/OCMock.h>
#import <OCMock/OCMArg.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIConstants.h>
#import <Simon/SIStoryFileReader.h>
#import <Simon/SIHttpAppBackpack.h>
#import <CocoaHTTPServer/HTTPServer.h>

// Hack into the process to update arguments for testing.
@interface NSProcessInfo (_hack)
- (void)setArguments:(id)arg1;
@end

@interface SIHttpAppBackpack (_hack)
-(HTTPServer *) server;
@end

@implementation SIHttpAppBackpack (_hack)
-(HTTPServer *) server {
	return server;
}
@end

@interface SIHttpAppBackpackTests : GHTestCase {
@private
	BOOL startRun;
	NSArray *originalArgs;
}
-(void) startRun:(NSNotification *) notification;
@end

@implementation SIHttpAppBackpackTests

-(void) setUp {
	originalArgs = [[[NSProcessInfo processInfo] arguments] retain];
	startRun = NO;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRun:) name:SI_RUN_STORIES_NOTIFICATION object:nil];
}

-(void) tearDown {
	[[NSProcessInfo processInfo] setArguments: originalArgs];
	DC_DEALLOC(originalArgs);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) testHttpBackpackStartsServerOnDefaultPort {
	NSArray *args = [NSArray arrayWithObjects:@"", nil];
	[[NSProcessInfo processInfo] setArguments:args];
	
	SIHttpAppBackpack *backpack = [[[SIHttpAppBackpack alloc] init] autorelease];
	HTTPServer *server = [backpack server];
	GHAssertEquals([server port], (UInt16) HTTP_SIMON_PORT, nil);
}


// Handlers.

-(void) startRun:(NSNotification *) notification {
	startRun = YES;
}

@end
