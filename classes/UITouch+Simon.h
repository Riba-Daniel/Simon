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

/// Property set to update the position in the window where the touch takes place. Note that this is in the windows co-ordinates, not the controls.
@property (nonatomic) CGPoint locationInWindow;

/**
 Default constructor.
 
 @param view the view that the touch will apply to.
 */
- (id)initInView:(UIView *)view;

/**
 Sets the phase of the touch. 
 
 @param phase the new phase. One of the values from UITouchPhase.
 */
- (void)setPhase:(UITouchPhase)phase;
@end
