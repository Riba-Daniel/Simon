//
//  PieMan.m
//  Simon
//
//  Created by Derek Clarkson on 28/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "PIPieMan.h"
#import <Simon/SIConstants.h>
#import <dUsefulStuff/DCCommon.h>
#import "PIHeartbeat.h"

// Pieman's background thread name.
#define PI_QUEUE_NAME "au.com.derekclarkson.pieman"

@interface PIPieMan () {
@private
	dispatch_queue_t queue;
	PIHeartbeat *heartbeat;
	
}

-(void) executeOnPieManThread:(void (^)()) block;

@end

@implementation PIPieMan

@synthesize finished = _finished;

-(void) dealloc {
	dispatch_release(queue);
	DC_DEALLOC(heartbeat);
	[super dealloc];
}

-(id) init {
	self = [super init];
	if (self) {
		_finished = NO;
		queue = dispatch_queue_create(PI_QUEUE_NAME, 0);
		heartbeat = [[PIHeartbeat alloc] init];
		heartbeat.delegate = self;
	}
	return self;
}

-(void) start {
	[heartbeat start];
}

#pragma mark - Delegate methods.

-(void) heartbeatDidEnd {
	_finished = YES;
	DC_LOG(@"Heart beat ended.");
}

#pragma mark - Thread methods

-(void) executeOnPieManThread:(void (^)()) block {
	dispatch_async(queue, ^{
		DC_LOG(@"Executing block on Simon's background thread");
		[NSThread currentThread].name = @"Pieman";
		block();
	});
}

@end
