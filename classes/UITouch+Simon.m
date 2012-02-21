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
- (id)initInView:(UIView *)view {
	self = [super init];
	if (self) {
      
      // Locate the frame of the view in the window.
		CGRect frameInWindow;
		if ([view isKindOfClass:[UIWindow class]]) {
			frameInWindow = view.frame;
		}
		else {
			frameInWindow = [view.window convertRect:view.frame fromView:view.superview];
		}
		DC_LOG_CGRECT(@"View frame in window co-rds", frameInWindow);
      
      
		// Find the deepest view at the cursor position.
      [self setLocationInWindow:CGPointMake(
                                            frameInWindow.origin.x + 0.5 * frameInWindow.size.width,
                                            frameInWindow.origin.y + 0.5 * frameInWindow.size.height)];
      
      // If a table viw we need to tap the table view, not the control within it.
		UIView *target = [view.window hitTest:self.locationInWindow withEvent:nil];
      //target = view;
		DC_LOG(@"Deepest target at point is a: %@", NSStringFromClass([target class]));
      
		_window = [view.window retain];
		_view = [target retain];
		_phase = UITouchPhaseBegan;
		_tapCount = 1;
      _touchFlags._firstTouchForView = YES;
      
   }
   
   
	return self;
}

- (void)setPhase:(UITouchPhase)phase
{
   _savedPhase = _phase;
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
   DC_LOG(@"Setting touch point in window from -> to: %i x %i -> %i x %i", (int)_previousLocationInWindow.x, (int)_previousLocationInWindow.y, (int)_locationInWindow.x, (int)_locationInWindow.y);
}

@end
