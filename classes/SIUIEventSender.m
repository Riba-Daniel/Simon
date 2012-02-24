//
//  SIUIEventSender.m
//  Simon
//
//  Created by Derek Clarkson on 24/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIUIEventSender.h"
#import "SIUIBackgroundThreadSender.h"
#import <dUsefulStuff/DCCommon.h>

@implementation SIUIEventSender

+(SIUIEventSender *) sender {
   if ([NSThread isMainThread]) {
      DC_LOG(@"Creating main thread sender");
      return [[[SIUIBackgroundThreadSender alloc] init] autorelease];
   } else {
      DC_LOG(@"Creating background thread sender");
      return [[[SIUIBackgroundThreadSender alloc] init] autorelease];
   }
}

-(void) scheduleEvent:(UIEvent *) event atTime:(dispatch_time_t) atTime {}

-(void) sendEvent:(UIEvent *) event {}

@end
