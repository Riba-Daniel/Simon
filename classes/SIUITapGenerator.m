//
//  SIUITapGenerator.m
//  Simon
//
//  Created by Derek Clarkson on 24/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIUITapGenerator.h"
#import "SIUIEventSender.h"
#import "UITouch+Simon.h"
#import "UIEvent+Simon.h"

@implementation SIUITapGenerator

-(void) sendEvents {
   DC_LOG(@"Creating tap sequence for a %@", NSStringFromClass([self.view class]));
   SIUIEventSender *sender = [SIUIEventSender sender];
   [sender sendEvent:event];
   [touch setPhase:UITouchPhaseEnded];
   [sender sendEvent:event];
}

@end
