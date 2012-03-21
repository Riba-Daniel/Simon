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
   dispatch_sync(mainQ, ^{

#ifdef DC_DEBUG
      UITouch *touch = [[event allTouches] anyObject];
      CGPoint loc = [touch locationInView:touch.window];
      DC_LOG(@"Sending touch event type %i @ %i x %i to UIView: %p", touch.phase, (int)loc.x, (int)loc.y, touch.view);
#endif
      
      // Send the event.
      [event updateTimeStamp];
		DC_LOG(@"Touch view %@", touch.view);
		DC_LOG(@"Touch Count %i", [[event allTouches] count]);
      [[UIApplication sharedApplication] sendEvent:event];
      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
   });
}

@end
