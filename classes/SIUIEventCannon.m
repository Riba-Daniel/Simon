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
   DC_LOG(@"Firing tap events");
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
