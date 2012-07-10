//
//  UITouch+Simon.m
//  Simon
//
//  Created by Derek Clarkson on 15/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "UITouch+Simon.h"

// These declarations are copies from the private apis and serve to give us access to the internals of UITouch.
@interface UITouch (Simon_UITouchInternal)
@property(retain, nonatomic) UIView* view;
@property(retain, nonatomic) UIWindow* window;
@property(assign, nonatomic) unsigned tapCount;
@property(assign, nonatomic) int phase;
@property(assign, nonatomic) double timestamp;
-(void)_pushPhase:(int)phase;
-(CGPoint)_locationInWindow:(id)window;
-(void)_setLocationInWindow:(CGPoint)window resetPrevious:(BOOL)previous;
-(void)_setIsFirstTouchForView:(BOOL)view;
@end

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
      
      // If a table view we need to tap the table view, not the control within it.
		UIView *target = [view.window hitTest:self.locationInWindow withEvent:nil];
		DC_LOG(@"Deepest target at point is a: %@: %p ", NSStringFromClass([target class]), target);
      
		self.window = view.window;
		self.view = target;
		self.phase = UITouchPhaseBegan;
		self.tapCount = 1;
		[self _setIsFirstTouchForView:YES];
      
   }
   
   
	return self;
}

- (void)setPhase:(UITouchPhase)phase
{
	[self _pushPhase: phase];
	self.timestamp = [NSDate timeIntervalSinceReferenceDate];
}

-(CGPoint) locationInWindow {
   return [self _locationInWindow:self.window];
}

- (void)setLocationInWindow:(CGPoint)location
{
	[self _setLocationInWindow:location resetPrevious:NO];
	self.timestamp = [NSDate timeIntervalSinceReferenceDate];
	CGPoint loc = [self _locationInWindow:self.window];
   DC_LOG(@"Setting new touch point %f x %f", loc.x, loc.y);
}

@end
