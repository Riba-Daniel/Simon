//
//  SIHttpAppBackpackTests.m
//  Simon
//
//  Created by Derek Clarkson on 5/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIConstants.h>
#import <Simon/SIStoryFileReader.h>
#import <Simon/SIHttpAppBackpack.h>
#import <CocoaHTTPServer/HTTPServer.h>

// Hack into the process to update arguments for testing.
@interface NSProcessInfo (_hack)
- (void)setArguments:(id)arg1;
@end

@interface SIHttpAppBackpackTests : GHTestCase {
@private
	BOOL startRun;
	NSProcessInfo *info;
	NSArray *originalArgs;
}
-(void) startRun:(NSNotification *) notification;
@end

@implementation SIHttpAppBackpackTests

-(void) setUp {
	info = [[NSProcessInfo processInfo] retain];
	originalArgs = [[info arguments] retain];
	startRun = NO;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRun:) name:SI_RUN_STORIES_NOTIFICATION object:nil];
}

-(void) tearDown {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSProcessInfo processInfo] setArguments: originalArgs];
	DC_DEALLOC(originalArgs);
	DC_DEALLOC(info);
}

-(void) testHttpBackpackStartsServerOnDefaultPort {
	NSArray *args = [NSArray arrayWithObjects:@"", nil];
	[[NSProcessInfo processInfo] setArguments:args];
	
	SIHttpAppBackpack *backpack = [[[SIHttpAppBackpack alloc] init] autorelease];
	HTTPServer *server = [backpack server];
	GHAssertEquals([server port], (UInt16) HTTP_SIMON_PORT, nil);
}

-(void) testHttpBackpackStartsServerOnCustomPort {
	NSArray *args = [NSArray arrayWithObjects:@"-simon-port", @"12345", nil];
	[[NSProcessInfo processInfo] setArguments:args];
	
	SIHttpAppBackpack *backpack = [[[SIHttpAppBackpack alloc] init] autorelease];
	HTTPServer *server = [backpack server];
	GHAssertEquals([server port], (UInt16) 12345, nil);
}


// Handlers.

-(void) startRun:(NSNotification *) notification {
	startRun = YES;
}

@end
