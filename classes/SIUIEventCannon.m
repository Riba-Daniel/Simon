//
//  SIEventCannon.m
//  Simon
//
//  Created by Derek Clarkson on 21/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIUIEventCannon.h"
#import <dUsefulStuff/DCCommon.h>
#import "SIConstants.h"
#import "UITouch+Simon.h"
#import "UIEvent+Simon.h"

@interface SIUIEventCannon(_private)
-(void) sendEvent:(UIEvent *) event andPauseFor:(NSTimeInterval) pause;
-(void) sendEvent:(UIEvent *) event;
@end

@implementation SIUIEventCannon

-(void) dealloc {
   dispatch_release(cannonQueue);
   [super dealloc];
}

-(id) init {
   self = [super init];
   if (self) {
      cannonQueue = dispatch_queue_create(SI_EVENT_CANNON_QUEUE_NAME, NULL);
      mainQ = dispatch_get_main_queue();
   }
   return self;
}

-(void) tapView:(UIView *) view {
   DC_LOG(@"Firing tap events at a %@", NSStringFromClass([view class]));
   dispatch_sync(cannonQueue, ^{
      dispatch_sync(mainQ, ^{
         DC_LOG(@"Creating tap sequence for a %@", NSStringFromClass([view class]));
         
         UITouch *touch = [[[UITouch alloc] initInView:view] autorelease];
         UIEvent *event = [[[NSClassFromString(@"UITouchesEvent") alloc] initWithTouch:touch] autorelease];
         [self sendEvent:event];
         
         [touch setPhase:UITouchPhaseEnded];
         [self sendEvent:event];
      });
   });
}

-(void) swipeView:(UIView *) view direction:(SIUISwipeDirection) swipeDirection distance:(int) distance {
   DC_LOG(@"Firing swipe events at a %@", NSStringFromClass([view class]));
   dispatch_sync(cannonQueue, ^{
      dispatch_sync(mainQ, ^{
         
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
         UITouch *touch = [[[UITouch alloc] initInView:view] autorelease];
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
         
      });
   });
}

#pragma mark - Private methods

-(void) sendEvent:(UIEvent *) event {
   
   DC_LOG(@"Sending touch event type %i", [[[event allTouches] anyObject] phase]);
   
   // Send the event.
   [event updateTimeStamp];
	[[UIApplication sharedApplication] sendEvent:event];
   
   // Fire the current run loop which will be the main one.
   [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
}

-(void) sendEvent:(UIEvent *) event andPauseFor:(NSTimeInterval) pause {
   [self sendEvent:event];
   [NSThread sleepForTimeInterval:pause];
}

@end
