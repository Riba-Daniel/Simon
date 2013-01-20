//
//  SIUIApplication+Actions.h
//  Simon
//
//  Created by Derek Clarkson on 4/01/13.
//  Copyright (c) 2013 Sensis. All rights reserved.
//

#import <Simon/Simon.h>

/**
 Category of actions that can be taken on interface controls.
 */

@interface SIUIApplication (Actions)

/// @name Tapping

/**
 Taps the specified view.
 
 @param view the view to be tapped.
 */
-(void) tap:(UIView *) view;

/**
 Taps the specified view at the specified location.
 
 @param view the UIView to be tapped.
 @param atPoint where to tap the view.
 */
-(void) tap:(UIView *) view atPoint:(CGPoint) atPoint;

#pragma mark - Swiping

/// @name Swiping

/**
 Performs a swipe on the specified UIView. Currently there are 4 basic directions.
 
 @param view a UIView we want to swipe. The swipe will start from the center of that UIView.
 @param swipeDirection a value from SIUISwipeDirection indicting the direction to swipe in.
 @param distance how far to swipe in the given direction.
 */
-(void) swipe:(UIView *) view inDirection:(SIUISwipeDirection) swipeDirection forDistance:(int) distance;

@end
