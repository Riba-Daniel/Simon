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

@synthesize view = view_;

-(void) dealloc {
   self.view = nil;
   [super dealloc];
}

-(id) initWithView:(UIView *) view {
   self = [super init];
   if (self) {
      self.view = view;
   }
   return self;
}


-(void) sendEvents {
   
   DC_LOG(@"Creating tap sequence for a %@", NSStringFromClass([self.view class]));
   
   UITouch *touch = [[[UITouch alloc] initInView:self.view] autorelease];
   UIEvent *event = [[[NSClassFromString(@"UITouchesEvent") alloc] initWithTouch:touch] autorelease];

   SIUIEventSender *sender = [SIUIEventSender sender];
   
   [sender sendEvent:event];
   
   [touch setPhase:UITouchPhaseEnded];
   [sender sendEvent:event];

}

@end
