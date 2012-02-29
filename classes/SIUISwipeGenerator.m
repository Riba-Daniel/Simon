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
      self.distance = 80;
      self.eps = 50;
      self.duration = 0.5;
      self.swipeDirection = SIUISwipeDirectionLeft;
   }
   return self;
}


-(void) sendEvents {
   
   // Calculate the number of events to generate and the distance between them.
   int nbrMoves = round(self.eps * self.duration);
   CGFloat touchAdjust = (CGFloat) self.distance / (CGFloat) nbrMoves;

   // Calculate the event interval between events to achieve this.
   NSTimeInterval frameDuration = self.duration / nbrMoves;

   // Work out the offsets to use on the x and y axis.
   CGFloat touchAdjustX = self.swipeDirection == SIUISwipeDirectionRight ? touchAdjust : self.swipeDirection == SIUISwipeDirectionLeft ? -touchAdjust : 0;
   CGFloat touchAdjustY = self.swipeDirection == SIUISwipeDirectionDown ? touchAdjust : self.swipeDirection == SIUISwipeDirectionUp ? -touchAdjust : 0;
   
   SIUIEventSender *sender = [SIUIEventSender sender];

   // Send the touch and trigger the run loop, then pause for the amount of time needed between touches.
   UITouch *touch = [[[UITouch alloc] initInView:self.view] autorelease];
   UIEvent *event = [[[NSClassFromString(@"UITouchesEvent") alloc] initWithTouch:touch] autorelease];
   
   // Send the starting event.
   [sender sendEvent:event];
   [NSThread sleepForTimeInterval:frameDuration];
   
   DC_LOG(@"Swipe setup:-");
   DC_LOG(@"   direction           : %i", self.swipeDirection);
   DC_LOG(@"   distance            : %i", self.distance);
   DC_LOG(@"   eps                 : %i", self.eps);
   DC_LOG(@"   number moves        : %i", nbrMoves);
   DC_LOG(@"   Move distance       : %f", touchAdjust);
   DC_LOG(@"   Move distance X     : %f", touchAdjustX);
   DC_LOG(@"   Move distance Y     : %f", touchAdjustY);
   DC_LOG(@"   frame duration      : %f", frameDuration);
   
   // Loop and generate the intermediary move events.
   [touch setPhase:UITouchPhaseMoved];
   for (int i = 1; i < nbrMoves; i++) {
      // Setup the dispatch time.
      touch.locationInWindow = CGPointMake(touch.locationInWindow.x + touchAdjustX, touch.locationInWindow.y + touchAdjustY);
      [sender sendEvent:event];
      [NSThread sleepForTimeInterval:frameDuration];
   }
   
   // Send the ending event.
   touch.locationInWindow = CGPointMake(touch.locationInWindow.x + touchAdjustX, touch.locationInWindow.y + touchAdjustY);
   [touch setPhase:UITouchPhaseEnded];
   [sender sendEvent:event];
   
}

@end
