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
 Perform a tap on the view at a specific location.
 
 @param atPoint where you want the tap to occur.
 */
-(void) tapAtPoint:(CGPoint) atPoint;

/**
 Performs a swipe is the specified direction.
 
 @param swipeDirection a SIUISwipeDirection specifying the direction to swipe.
 @param distance the distance to swipe in screen points.
 */
-(void) swipe:(SIUISwipeDirection) swipeDirection distance:(int) distance;

/**
 This allows UIViews which accept text to have text entered. It will only work on UIViews that implement the UITextInput protocol.
 
 @param text the text you want entered into the control. This will be sent via a private API on the keyboard.
 @param keyRate how fast the text should be entered. This is the amunt of time to wait between sending each key.
 @param autoCorrect if YES (default) allows text entered to be autocorrected.
 */
-(void) enterText:(NSString *) text keyRate:(NSTimeInterval) keyRate autoCorrect:(BOOL) autoCorrect;

@end
