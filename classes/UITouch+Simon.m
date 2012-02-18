//
//  UITouch+Simon.m
//  Simon
//
//  Created by Derek Clarkson on 15/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "UITouch+Simon.h"

@implementation UITouch (Simon)


@dynamic locationInWindow;
//
// initInView:phase:
//
// Creats a UITouch, centered on the specified view, in the view's window.
// Sets the phase as specified.
//
- (id)initInView:(UIView *)view
{
	self = [super init];
	if (self != nil)
	{
		CGRect frameInWindow;
		if ([view isKindOfClass:[UIWindow class]])
		{
			DC_LOG(@"Using views frame");
			frameInWindow = view.frame;
		}
		else
		{
			frameInWindow = [view.window convertRect:view.frame fromView:view.superview];
		}
		DC_LOG_CGRECT(@"View frame in window co-rds", frameInWindow);
      
		_tapCount = 1;
      
		// Find the deepest view at the cursor position.
      [self setLocationInWindow:CGPointMake(
                                      frameInWindow.origin.x + 0.5 * frameInWindow.size.width,
                                      frameInWindow.origin.y + 0.5 * frameInWindow.size.height)];
		UIView *target = [view.window hitTest:_locationInWindow withEvent:nil];
		DC_LOG(@"Deepest target at point: %@", target);
      
		_window = [view.window retain];
		_view = [target retain];
		_phase = UITouchPhaseBegan;
      // Always on.
		_touchFlags._firstTouchForView = YES;
		//_touchFlags._isTap = 1;
	}
	return self;
}

- (void)setPhase:(UITouchPhase)phase
{
   DC_LOG(@"Phase: %i", phase);
	_phase = phase;
	_timestamp = [NSDate timeIntervalSinceReferenceDate];
}

-(CGPoint) locationInWindow {
   return _locationInWindow;
}

- (void)setLocationInWindow:(CGPoint)location
{
	_previousLocationInWindow = _locationInWindow;
	_locationInWindow = location;
	_timestamp = [NSDate timeIntervalSinceReferenceDate];
   DC_LOG(@"Touch point: %i x %i", (int)_locationInWindow.x, (int)_locationInWindow.y);
}

@end
