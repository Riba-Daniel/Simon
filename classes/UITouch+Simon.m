//
//  UITouch+Simon.m
//  Simon
//
//  Created by Derek Clarkson on 15/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "UITouch+Simon.h"

@implementation UITouch (Simon)
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
			DC_LOG(@"Locating views frame in the window via it's superview");
			frameInWindow =
         [view.window convertRect:view.frame fromView:view.superview];
		}
		DC_LOG_CGRECT(@"View frame in window", frameInWindow);
      
		_tapCount = 1;
      
		// Find the deepest view at the cursor position.
		_locationInWindow = CGPointMake(
                                      frameInWindow.origin.x + 0.5 * frameInWindow.size.width,
                                      frameInWindow.origin.y + 0.5 * frameInWindow.size.height);
		DC_LOG(@"Center point %f x %f", _locationInWindow.x, _locationInWindow.y);
		_previousLocationInWindow = _locationInWindow;
		UIView *target = [view.window hitTest:_locationInWindow withEvent:nil];
		DC_LOG(@"Deepest target at point: %@", target);
      
		_window = [view.window retain];
		_view = [target retain];
		_phase = UITouchPhaseBegan;
		_touchFlags._firstTouchForView = 1;
		_touchFlags._isTap = 1;
		_timestamp = [NSDate timeIntervalSinceReferenceDate];
	}
	return self;
}

- (void)setPhase:(UITouchPhase)phase
{
	_phase = phase;
	_timestamp = [NSDate timeIntervalSinceReferenceDate];
}

- (void)setLocationInWindow:(CGPoint)location
{
	_previousLocationInWindow = _locationInWindow;
	_locationInWindow = location;
	_timestamp = [NSDate timeIntervalSinceReferenceDate];
}

@end
