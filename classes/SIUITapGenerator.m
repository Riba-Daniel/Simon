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

@synthesize tapPoint;

-(id) initWithView:(UIView *) view {
   self = [super initWithView:view];
   if (self) {
      self.tapPoint = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
   }
   return self;
}

-(void) sendEvents {
   DC_LOG(@"Creating tap sequence for a %@", NSStringFromClass([self.view class]));
	
	// Position the tap if needed.
	if (!CGPointEqualToPoint(self.tapPoint, CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX))) {
		[touch setLocationInWindow:[self.view pointInWindowFromPointInView:self.tapPoint]];
	}
	
	// Now tap.
   SIUIEventSender *sender = [SIUIEventSender sender];
   [sender sendEvent:event];
   [touch setPhase:UITouchPhaseEnded];
   [sender sendEvent:event];
}

@end
