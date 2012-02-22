//
//  SIUIViewHandler.m
//  Simon
//
//  Created by Derek Clarkson on 13/09/11.
//  Copyright (c) 2011. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import "SIUIViewHandler.h"
#import "UITouch+Simon.h"
#import "UIEvent+Simon.h"

@interface SIUIViewHandler(_private)
-(UIEvent *) sendEvent:(UIEvent *) event andPauseFor:(NSTimeInterval) pause;
-(UIEvent *) sendEvent:(UIEvent *) event;
@end


@implementation SIUIViewHandler

@synthesize view = view_;
@synthesize eventCannon = eventCannon_;

-(void) dealloc {
   self.view = nil;
   self.eventCannon = nil;
   [super dealloc];
}

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
   [self.eventCannon tapView:self.view];
}

-(void) swipe:(SIUISwipeDirection) swipeDirection distance:(int) distance {
   
	// Redirect to the main thread.
	if (![[NSThread currentThread] isMainThread]) {
		DC_LOG(@"Redirecting to main thread");
      dispatch_queue_t mainQ = dispatch_get_main_queue();
      dispatch_sync(mainQ, ^{
         [self swipe:swipeDirection distance:distance];
      });
      return;
	}
	
	DC_LOG(@"Creating swipe sequence for a %@", NSStringFromClass([self.view class]));
	
   // Calculate the event framerate and interval between events to achieve this.
   CGFloat duration = 0.25;
   CGFloat fps = 72;
   NSTimeInterval frameDuration = 1 / fps;
   
   // Calculate the number of events to generate and the distance between them.
   int nbrTicks = fps * duration;
   CGFloat tickDistance = distance / nbrTicks;
   
   // Work out the offsets to use on the x and y axis.
   CGFloat tickDistanceX = swipeDirection == SIUISwipeDirectionRight ? tickDistance: swipeDirection == SIUISwipeDirectionLeft ? -tickDistance: 0;
   CGFloat tickDistanceY = swipeDirection == SIUISwipeDirectionDown ? tickDistance : swipeDirection == SIUISwipeDirectionUp ? -tickDistance : 0;
   
   // Send the touch and trigger the run loop, then pause for the amount of time needed between touches.
   UITouch *touch = [[[UITouch alloc] initInView:self.view] autorelease];
   UIEvent *event = [[[NSClassFromString(@"UITouchesEvent") alloc] initWithTouch:touch] autorelease];
   [self sendEvent:event andPauseFor:frameDuration];

   // Loop and generate the intermediary move events.
   [touch setPhase:UITouchPhaseMoved];
   for (int i = 1; i <= nbrTicks; i++) {
      touch.locationInWindow = CGPointMake(touch.locationInWindow.x + tickDistanceX, touch.locationInWindow.y + tickDistanceY);
      [self sendEvent:event andPauseFor:frameDuration];
   }
   
   // Send the ending event.
   [touch setPhase:UITouchPhaseEnded];
   [self sendEvent:event];
}

-(UIEvent *) sendEvent:(UIEvent *) event {
   return [self sendEvent:event andPauseFor:0.0];
}

-(UIEvent *) sendEvent:(UIEvent *) event andPauseFor:(NSTimeInterval) pause {
   
   DC_LOG(@"Sending touch event type %i", [[[event allTouches] anyObject] phase]);
   
   [event updateTimeStamp];
	[[UIApplication sharedApplication] sendEvent:event];
   
   // Allow the display to receive the event and pause if asked to.
   [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
   if (pause > 0.0) {
      [NSThread sleepForTimeInterval:pause];
   }
   return event;
   
}


@end
