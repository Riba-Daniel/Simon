//
//  SIUITapGenerator.m
//  Simon
//
//  Created by Derek Clarkson on 24/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import <UIKit/UIKit.h>

#import "SIUITapGenerator.h"
#import "UITouch+Simon.h"
#import "UIEvent+Simon.h"
#import "UIView+Simon.h"

@implementation SIUITapGenerator

@synthesize tapPoint;

-(id) initWithView:(UIView *) view {
   self = [super initWithView:view];
   if (self) {
      self.tapPoint = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
   }
   return self;
}

-(void) generateEvents {
	
   DC_LOG(@"Creating tap sequence for UIView: %p", self.view);
	
	// Position the tap if needed.
	if (!CGPointEqualToPoint(self.tapPoint, CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX))) {
		[touch setLocationInWindow:[self.view pointInWindowFromPointInView:self.tapPoint]];
	}
	
	// Now tap.
   [self sendEvent];
   [touch setPhase:UITouchPhaseEnded];
   [self sendEvent];
}

@end
