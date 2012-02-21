//
//  SIUIAction.h
//  Simon
//
//  Created by Derek Clarkson on 8/08/11.
//  Copyright 2011. All rights reserved.
//

#import "SIUIConstants.h"

/**
 This protocol outlines the possible actions that can be performed on a control. For example taps, swipes etc. It is implemented 
 by the handlers for the various UI classes.
 */
@protocol SIUIAction

/**
 Perform a tap on the view.
 */
-(void) tap;

/**
 Performs a swipe is the specified direction.
 
 @param swipeDirection a SIUISwipeDirection specifying the direction to swipe.
 @param distance the distance to swipe in screen points.
 */
-(void) swipe:(SIUISwipeDirection) swipeDirection distance:(int) distance;

@end
