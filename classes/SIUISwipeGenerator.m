//
//  SIUISwipeGenerator.m
//  Simon
//
//  Created by Derek Clarkson on 24/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIUISwipeGenerator.h"
#import "UITouch+Simon.h"
#import "UIEvent+Simon.h"
#import "SIUIEventSender.h"

@implementation SIUISwipeGenerator

@synthesize view = view_;
@synthesize distance = distance_;
@synthesize eps = eps_;
@synthesize duration = duration_;
@synthesize swipeDirection = swipeDirection_;

-(void) dealloc {
   self.view = nil;
   [super dealloc];
}

-(id) initWithView:(UIView *) view {
   self = [super init];
   if (self) {
      self.view = view;
      self.distance = 60;
      self.eps = 48;
      self.duration = 0.25;
      self.swipeDirection = SIUISwipeDirectionLeft;
   }
   return self;
}


-(void) sendEvents {
   
   // Calculate the event framerate and interval between events to achieve this.
   NSTimeInterval frameDuration = 1 / self.eps * 1000 * 1000;
   
   // Calculate the number of events to generate and the distance between them.
   int nbrTicks = self.eps * self.duration;
   CGFloat tickDistance = self.distance / nbrTicks;
   
   // Work out the offsets to use on the x and y axis.
   CGFloat tickDistanceX = self.swipeDirection == SIUISwipeDirectionRight ? tickDistance: self.swipeDirection == SIUISwipeDirectionLeft ? -tickDistance: 0;
   CGFloat tickDistanceY = self.swipeDirection == SIUISwipeDirectionDown ? tickDistance : self.swipeDirection == SIUISwipeDirectionUp ? -tickDistance : 0;

   SIUIEventSender *sender = [SIUIEventSender sender];

   // Send the touch and trigger the run loop, then pause for the amount of time needed between touches.
   UITouch *touch = [[[UITouch alloc] initInView:self.view] autorelease];
   UIEvent *event = [[[NSClassFromString(@"UITouchesEvent") alloc] initWithTouch:touch] autorelease];
   
   // Send the starting event.
   [sender sendEvent:event];
   
   // Setup the dispatch time.
   dispatch_time_t nextEventTime = dispatch_time(DISPATCH_TIME_NOW, frameDuration);
   
   // Loop and generate the intermediary move events.
   [touch setPhase:UITouchPhaseMoved];
   for (int i = 1; i <= nbrTicks; i++) {
      // Setup the dispatch time.
      nextEventTime = dispatch_time(nextEventTime, frameDuration);
      touch.locationInWindow = CGPointMake(touch.locationInWindow.x + tickDistanceX, touch.locationInWindow.y + tickDistanceY);
      [sender scheduleEvent:event atTime:nextEventTime];
   }
   
   // Send the ending event.
   [touch setPhase:UITouchPhaseEnded];
   [sender sendEvent:event];
   
}

@end
