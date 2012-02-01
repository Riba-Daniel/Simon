//
//  TouchSynthesis.h
//  SelfTesting
//
//  Created by Matt Gallagher on 23/11/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <UIKit/UIKit.h>

/**
 UITouch (Synthesize)

 Category to allow creation and modification of UITouch objects.
*/
@interface UITouch (Synthesize)

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

/**
 UIEvent (Synthesize)

 A category to allow creation of a touch event.
*/
@interface UIEvent (Synthesize)

/**
 Default constructor.
 
 @param touch the UITouch to init with.
 */
- (id)initWithTouch:(UITouch *)touch;

@end
