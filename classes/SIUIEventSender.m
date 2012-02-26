//
//  SIUIEventSender.m
//  Simon
//
//  Created by Derek Clarkson on 24/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//
#import <dUsefulStuff/DCCommon.h>

#import "SIUIEventSender.h"
#import "SIUIBackgroundThreadSender.h"
#import "SIUIMainThreadSender.h"

@implementation SIUIEventSender

+(SIUIEventSender *) sender {
   return [[[SIUIEventSender alloc] init] autorelease];
}

+ (id)alloc {
   if ([NSThread isMainThread]) {
      DC_LOG(@"Creating main thread sender");
      return [SIUIMainThreadSender allocWithZone:nil];
   } else {
      DC_LOG(@"Creating background thread sender");
      return [SIUIBackgroundThreadSender allocWithZone:nil];
   }
}

-(void) scheduleEvent:(UIEvent *) event atTime:(dispatch_time_t) atTime {}

-(void) sendEvent:(UIEvent *) event {}

@end



