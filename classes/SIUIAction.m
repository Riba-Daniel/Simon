//
//  SIUIAction.m
//  Simon
//
//  Created by Derek Clarkson on 8/08/11.
//  Copyright 2011. All rights reserved.
//
#import <dUsefulStuff/DCCommon.h>

#import "SIUIAction.h"
#import "TouchSynthesis.h"

@implementation SIUIAction

@synthesize view;

-(id) initWithView:(UIView *) aView {
    self = [super init];
    if (self) {
		 self.view = aView;
    }
    
    return self;
}

-(void) tap {

	// Redirect to the main thread.
	if (![[NSThread currentThread] isMainThread]) {
		DC_LOG(@"Redirecting to main thread");
		[self performSelectorOnMainThread:@selector(tap) withObject:nil waitUntilDone:YES];
		return;
	}
	
	DC_LOG(@"Creating touch sequence for control %@", self);
	
	UITouch *touch = [[UITouch alloc] initInView:self.view];
	UIEvent *eventDown = [[UIEvent alloc] initWithTouch:touch];
	[[UIApplication sharedApplication] sendEvent:eventDown];
	
	[touch setPhase:UITouchPhaseEnded];
	UIEvent *eventUp = [[UIEvent alloc] initWithTouch:touch];
	
	[[UIApplication sharedApplication] sendEvent:eventUp];
	
	[eventDown release];
	[eventUp release];
	[touch release];
	
}

@end
