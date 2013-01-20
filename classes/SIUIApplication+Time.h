//
//  SIUIApplication+Time.h
//  Simon
//
//  Created by Derek Clarkson on 4/01/13.
//  Copyright (c) 2013 Sensis. All rights reserved.
//

#import <Simon/SIUIApplication.h>

/**
 Methods which effective the flow of the test.
 */

@interface SIUIApplication (Time)

/// @name Pauses and waits

/**
 Pauses the current thread for the specified time. Use this to hold a background test thread whilst waiting for the UI to update.
 
 @param duration how long to hold the current thread for.
 */
-(void) pauseFor:(NSTimeInterval) duration;

/**
 Examines the UI using the query. It the query sucessfully returns a single view, then this method ends and returns the view. If the query is not successful, the the method sleeps for the specified time interval and tries again. If the the maximum number of retries is reached doing this, an exception is raised.
 
 This method is of most use when there are animations involved in the display.
 
 @param query the query that should find the control.
 @param interval the time interval between attemts to find the control.
 @param maxRetries how many times to attempt to find the control before giving up.
 @return the control if found.
 */
-(UIView *) waitForViewWithQuery:(NSString *) query retryInterval:(NSTimeInterval) interval maxRetries:(int) maxRetries;

/**
 Waits for an animation to finish before returning. If the control is not present this method will first wait for it to appear by calling
 waitFirViewWithQuery:retryInterval:maxRetries using the same retryInterval and a maxRetries of 20.
 
 The process of assessing if an animation is finished is not simple. To achieve it we access the views CALayer and check it for animation
 keys. If there are none, we assume the animations have finished. Note that this takes into account any animations running on super views as well. So you can check a control which is on a view which is sliding on and it will be regarded as being animated even though the control itself is not.
 
 @param query the query that should find the control.
 @param interval the time interval between animation checks.
 */
-(void) waitForAnimationEndOnViewWithQuery:(NSString *) query retryInterval:(NSTimeInterval) interval;

@end
