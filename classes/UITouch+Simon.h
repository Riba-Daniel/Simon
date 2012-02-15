//
//  UITouch+Simon.h
//  Simon
//
//  Created by Derek Clarkson on 15/02/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 This category opens the UITouch class so that touches can be created programmatically. It is based on the excellant work done by Matt Gallagher.
 */
@interface UITouch (Simon)

/**
 Default constructor.
 
 @param view the view that the touch will apply to.
 */
- (id)initInView:(UIView *)view;

/**
 Sets the phase of the touch.
 
 @param phase the phase to set.
 */
- (void)setPhase:(UITouchPhase)phase;

/**
 Sets the location of the touch in the view.
 
 @param location where in the view.
 */
- (void)setLocationInWindow:(CGPoint)location;

@end
