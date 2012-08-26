//
//  SIHttpRunAllRequestTests.m
//  Simon
//
//  Created by Derek Clarkson on 24/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import <GHUnitIOS/GHUnit.h>
#import <Simon/SIHttpRunAllRequestProcessor.h>

@interface SIHttpRunAllRequestTests : GHTestCase {
	@private
	SIHttpRunAllRequestProcessor *processor;
	BOOL notificationFired;
}

-(void) notificationFired:(NSNotification *) notification;

@end

@implementation SIHttpRunAllRequestTests

-(void) setUp {
	processor = [[SIHttpRunAllRequestProcessor alloc] init];
	notificationFired = NO;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationFired:) name:SI_RUN_STORIES_NOTIFICATION object:nil];
}

-(void) tearDown {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	DC_DEALLOC(processor);
}

-(void) testCanProcessPathAndMethodWithCorrectRequest {
	GHAssertTrue([processor canProcessPath:@"/run/all" withMethod:SIHttpMethodPost], nil);
}

-(void) testCanProcessPathAndMethodWithOtherRequest {
	GHAssertFalse([processor canProcessPath:@"/xxx" withMethod:SIHttpMethodPost], nil);
}

-(void) testProcessPathWithMethodFiresNotification {
	
	[processor processPath:@"/run/all" withMethod:SIHttpMethodPost andBody:nil];
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	
	GHAssertTrue(notificationFired, nil);
	
}

-(void) notificationFired:(NSNotification *) notification {
	notificationFired = YES;
}

@end