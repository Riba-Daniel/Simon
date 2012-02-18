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
-(UITouch *) touchView:(UIView *) view forPhase:(UITouchPhase) phase;
-(UITouch *) touchView:(UIView *) view forPhase:(UITouchPhase) phase atWindowLocation:(CGPoint) location;
-(UIEvent *) sendTouch:(UITouch *) touch;
@end


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
	
	DC_LOG(@"Creating touch sequence for control %@", self.view);
   UITouch * previousTouch = [self touchView:self.view forPhase:UITouchPhaseBegan];
   [self sendTouch:previousTouch];
   UITouch * lastTouch = [self touchView:self.view forPhase:UITouchPhaseEnded];
   [self sendTouch:lastTouch];
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
	
	DC_LOG(@"Creating swipe sequence for control %@", self.view);
	
   // Calculate the event framerate and interval between events to achieve this.
   CGFloat duration = 0.25;
   CGFloat fps = 48;
   NSTimeInterval frameDuration = 1 / fps;

   // Calculate the number of events to generate and the distance between them.
   int nbrTicks = fps * duration;
   CGFloat tickDistance = distance / nbrTicks;

   // Send the touch and trigger the run loop, then pause for the amount of time needed between touches.
   UITouch * previousTouch = [self touchView:self.view forPhase:UITouchPhaseBegan];
   [self sendTouch:previousTouch];
   [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
   [NSThread sleepForTimeInterval:frameDuration];

   // Loop and generate the intermediary move events.
   UITouch * nextTouch;
   for (int i = 0; i < nbrTicks; i++) {

      nextTouch = [self touchView:self.view forPhase:UITouchPhaseMoved atWindowLocation:CGPointMake(previousTouch.locationInWindow.x + tickDistance, previousTouch.locationInWindow.y)];
      [self sendTouch:nextTouch];
      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
      [NSThread sleepForTimeInterval:frameDuration];

      previousTouch = nextTouch;
      
   }

   // Send the ending event.
   UITouch * lastTouch = [self touchView:self.view forPhase:UITouchPhaseEnded atWindowLocation:previousTouch.locationInWindow];
   [self sendTouch:lastTouch];

}

-(UITouch *) touchView:(UIView *) view forPhase:(UITouchPhase) phase {
	UITouch *touch = [[[UITouch alloc] initInView:view] autorelease];
   [touch setPhase:phase];
   return touch;
}

-(UITouch *) touchView:(UIView *) view forPhase:(UITouchPhase) phase atWindowLocation:(CGPoint) location {
	UITouch *touch = [self touchView:view forPhase:phase];
   [touch setLocationInWindow:location];
   return touch;
}

-(UIEvent *) sendTouch:(UITouch *) touch {
   DC_LOG(@"Sending touch event");
	UIEvent *event = [[[UIEvent alloc] initWithTouch:touch] autorelease];
	[[UIApplication sharedApplication] sendEvent:event];
   return event;
   
}


@end
