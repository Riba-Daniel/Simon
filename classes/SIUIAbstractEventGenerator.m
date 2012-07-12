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
#import <Simon-core/NSObject+Simon.h>

@implementation SIUIAbstractEventGenerator

@synthesize view = view_;

-(id) initWithView:(UIView *) view {
	self = [super init];
	if (self) {
		
		self.view = view;
		
		// Touches and events must be created on the main queue.
		// Otherwise a 0xbbadbeef crash may occur.
		DC_LOG(@"Creating touch and event for %@: %p", NSStringFromClass([view class]), view);
		[self executeBlockOnMainThread: ^{
			touch = [[UITouch alloc] initInView:view];
			event = [[NSClassFromString(@"UITouchesEvent") alloc] initWithTouch:touch];
		}];
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

-(void) generateEvents{}


-(void) sendEvent {
	[self executeBlockOnMainThread:^{
		
#ifdef DC_DEBUG
      CGPoint loc = [touch locationInView:touch.window];
      DC_LOG(@"Sending touch event type %i @ %i x %i to UIView: %p", touch.phase, (int)loc.x, (int)loc.y, touch.view);
#endif
      
      // Send the event.
      [event updateTimeStamp];
      [[UIApplication sharedApplication] sendEvent:event];
      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
   }];
}


@end
