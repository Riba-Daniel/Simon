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
#import <Simon/SIStoryAnalyser.h>
#import <Simon/SIHttpAppBackpack.h>
#import <CocoaHTTPServer/HTTPServer.h>

// Hack into the process to update arguments for testing.
@interface NSProcessInfo (_hack)
- (void)setArguments:(id)arg1;
@end

@interface SIHttpAppBackpackTests : GHTestCase {
@private
	NSArray *originalArgs;
	SIHttpAppBackpack *backpack;
}
@end

@implementation SIHttpAppBackpackTests

-(void) setUp {
	originalArgs = [[[NSProcessInfo processInfo] arguments] retain];
}

-(void) tearDown {
	// Tell the backpack to clear processors.
	[backpack shutDown:nil];
	DC_DEALLOC(backpack);
	
	[[NSProcessInfo processInfo] setArguments: originalArgs];
	DC_DEALLOC(originalArgs);
}

-(void) testHttpBackpackStartsServerOnDefaultPort {
	NSArray *args = [NSArray arrayWithObjects:@"", nil];
	[[NSProcessInfo processInfo] setArguments:args];

	backpack = [[SIHttpAppBackpack alloc] init];

	HTTPServer *server = [backpack server];
	GHAssertEquals([server port], (UInt16) HTTP_SIMON_PORT, nil);
}

-(void) testHttpBackpackStartsServerOnCustomPort {
	NSArray *args = [NSArray arrayWithObjects:@"-simon-port", @"12345", nil];
	[[NSProcessInfo processInfo] setArguments:args];
	
	backpack = [[SIHttpAppBackpack alloc] init];
	HTTPServer *server = [backpack server];
	GHAssertEquals([server port], (UInt16) 12345, nil);
}

@end
