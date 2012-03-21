//
//  SIUIAbstractEventGenerator.m
//  Simon
//
//  Created by Derek Clarkson on 17/03/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIUIAbstractEventGenerator.h"
#import "UITouch+Simon.h"
#import "UIEvent+Simon.h"
#import <dUsefulStuff/DCCommon.h>

@implementation SIUIAbstractEventGenerator

@synthesize view = view_;

-(id) initWithView:(UIView *) view {
	self = [super init];
	if (self) {
		
		self.view = view;
		
		// Touches and events must be created on the main queue.
		// Otherwise a 0xbbadbeef crash may occur.
		// Use a block to conserve code.
		DC_LOG(@"Creating touch and event for UIView: %p", view);
		void (^createObjects)() = ^{
			touch = [[UITouch alloc] initInView:view];
			event = [[NSClassFromString(@"UITouchesEvent") alloc] initWithTouch:touch];
		};
		
		if ([NSThread isMainThread]) {
			createObjects();
		} else {
			// Goto the main Q.
			dispatch_queue_t mainQ = dispatch_get_main_queue();
			dispatch_sync(mainQ, ^{
				createObjects();
			});
		}
		
	}
	return self;
}

-(void) dealloc {
	DC_LOG(@"Releasing event and touch");
	self.view = nil;
	DC_DEALLOC(touch);
	DC_DEALLOC(event);
	[super dealloc];
}

-(void) sendEvents{}

@end
