//
//  SIEventCannon.m
//  Simon
//
//  Created by Derek Clarkson on 21/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import "UITouch+Simon.h"
#import "UIEvent+Simon.h"
#import "SIUIBackgroundThreadSender.h"

@implementation SIUIBackgroundThreadSender

-(id) init {
   self = [super init];
   if (self) {
      mainQ = dispatch_get_main_queue();
   }
   return self;
}

#pragma mark - Private methods

-(void) sendEvent:(UIEvent *) event {

   DC_LOG(@"Sending touch event type %i", [[[event allTouches] anyObject] phase]);

   dispatch_sync(mainQ, ^{
      // Send the event.
      [event updateTimeStamp];
      [[UIApplication sharedApplication] sendEvent:event];
      
      // Fire the current run loop which will be the main one.
      //[[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
   });
}

-(void) scheduleEvent:(UIEvent *) event atTime:(dispatch_time_t) atTime {

   DC_LOG(@"Scheduling touch event type %i at %f", [[[event allTouches] anyObject] phase], atTime);
   dispatch_after(atTime, mainQ, ^{
      [event updateTimeStamp];
      [[UIApplication sharedApplication] sendEvent:event];
      
      // Fire the current run loop which will be the main one.
      //[[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
   });
}

@end
