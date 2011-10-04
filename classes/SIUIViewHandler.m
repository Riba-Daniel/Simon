//
//  SIUIViewHandler.m
//  Simon
//
//  Created by Derek Clarkson on 13/09/11.
//  Copyright (c) 2011. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import "SIUIViewHandler.h"
#import "TouchSynthesis.h"

@implementation SIUIViewHandler

@synthesize view = view_;

#pragma mark - DNNode

-(NSString *)name {
	return NSStringFromClass([self.view class]);
}

-(NSObject<DNNode> *)parentNode {
	return (NSObject<DNNode> *) self.view.superview;
}

-(NSArray *)subNodes {
	// Return a copy as this has been known to change whilst this code is executing.
	return [[self.view.subviews copy] autorelease];	
}

-(BOOL) hasAttribute:(NSString *)attribute withValue:(id)value {
	// Use KVC to test the value.
	id propertyValue = [self.view valueForKeyPath:attribute];
	return [propertyValue isEqual:value];
}

#pragma mark - SIUIAction

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
