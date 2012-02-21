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

@property (nonatomic) CGPoint locationInWindow;

/**
 Default constructor.
 
 @param view the view that the touch will apply to.
 @param phase the phase to set.
 */
- (id)initInView:(UIView *)view;
- (void)setPhase:(UITouchPhase)phase;
@end
