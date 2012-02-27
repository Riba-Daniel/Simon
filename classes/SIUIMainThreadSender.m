//
//  SIUIMainThreadSender.m
//  Simon
//
//  Created by Derek Clarkson on 25/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIUIMainThreadSender.h"
#import "UITouch+Simon.h"
#import "UIEvent+Simon.h"

@implementation SIUIMainThreadSender

-(id) init {
   self = [super init];
   if (self) {
   }
   return self;
}

#pragma mark - Private methods

-(void) sendEvent:(UIEvent *) event {
   
   DC_LOG(@"Sending touch event type %i", [[[event allTouches] anyObject] phase]);
   [event updateTimeStamp];
   [[UIApplication sharedApplication] sendEvent:event];
   [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
}

@end
