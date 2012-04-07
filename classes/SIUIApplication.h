//
//  SIUIUtils.h
//  Simon
//
//  Created by Derek Clarkson on 7/23/11.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SIUIConstants.h"
#import "SIUIViewHandlerFactory.h"
#import "SIUIViewDescriptionVisitorDelegate.h"

/**
 Provides tools for accessing the UI of a running application.
 */
@interface SIUIApplication : NSObject<SIUIViewDescriptionVisitorDelegate> 

/// @name Properties

/// Factory which is used to generate view handlers for talking to UIView objects returned from queries. You can set this to a custom factory for implementing your own view handlers.
@property (retain, nonatomic) SIUIViewHandlerFactory *viewHandlerFactory;

/// If set to YES, disables the auto correction of entered text via the keyboard when using the enterText:intoField: method. This is useful for testing.
@property (nonatomic) BOOL disableKeyboardAutocorrect;

#pragma mark - Accessors

/** @name Singleton accessors */

/**
 Accesses the SIUIApplication singleton.
 */
+(SIUIApplication *) application;

#pragma mark - Finding

/** @name Finding things */

/**
 Executes the given query against the current window to locate one or more UIViews. Given that all interface controls inherit from UIView, this gives us the ability to locate any control on the display.
 
 This maps the xpath to the UI display by using class names of the controls as the xpath node names. 
 
 @param query an xpath as decribed by the dXpath static library.
 */
-(NSArray *) findViewsWithQuery:(NSString *) query;

/**
 Override of findViewsWithQuery: which expects to return only a single view.
 This is more strict because it will generate errors if 0 or multiple controls are found instead of the expected control.
 
 @param query an xpath as decribed by the dXpath static library.
 */
-(UIView *) findViewWithQuery:(NSString *) query;

/**
 returns YES if the query returns one or more UIViews. 
 
 @param query an xpath as decribed by the dXpath static library.
 */
-(BOOL) isViewPresent:(NSString *) query;

#pragma mark - Logging

/// @name Logging

/**
 Simple method which prints a tree view of the current UI to the console.
 */
-(void) logUITree;

#pragma mark - Tapping

/// @name Tapping

/**
 Locates a single UIView based on the passed query and taps at the exact center of that view.
 
 @param query the query that will locate the view. Zero or multiple returns from that query will trigger an error.
 @return the view that was tapped.
 */
-(UIView *) tapViewWithQuery:(NSString *) query;

/**
 Locates a single UIView based on the passed query and taps at the specified location.
 
 @param query the query that will locate the view. Zero or multiple returns from that query will trigger an error.
 @param atPoint where to tap the view.
 @return the view that was tapped.
 */
-(UIView *) tapViewWithQuery:(NSString *) query atPoint:(CGPoint) atPoint;

/**
 Searches for a button with a specific label taps it.
 
 @param label the text label of the icon we want to tap.
 */
-(void) tapButtonWithLabel:(NSString *) label;

/**
 Taps the specified view.
 
 @param view the UIView to be tapped.
 @return the view that was tapped.
 */
-(UIView *) tapView:(UIView *) view;

/**
 Taps the specified view at the specified location.
 
 @param view the UIView to be tapped.
 @param atPoint where to tap the view.
 @return the view that was tapped.
 */
-(UIView *) tapView:(UIView *) view atPoint:(CGPoint) atPoint;

/**
 Searches for a button with a specific label taps it, then waits for the specified period of time before returning. 
 
 @param label the text label of the icon we want to tap.
 @param seconds how many seconds or partial seconds to wait before continuing the current thread.
 */
-(void) tapButtonWithLabel:(NSString *) label andWait:(NSTimeInterval) seconds;

/**
 Searches for a tab bar and taps the button with the passed label.
 
 @param label the text label of the icon we want to tap.
 */
-(void) tapTabBarButtonWithLabel:(NSString *) label;

#pragma mark - Swiping

/// @name Swiping

/**
 Performs a swipe on the specified UIView. Currently there are 4 basic directions.
 
 @param view a UIView we want to swipe. The swipe will start from the center of that UIView.
 @param swipeDirection a value from SIUISwipeDirection indicting the direction to swipe in.
 @param distance how far to swipe in the given direction.
 @return the swiped view.
 */
-(UIView *) swipeView:(UIView *) view inDirection:(SIUISwipeDirection) swipeDirection forDistance:(int) distance;

/**
 Performs a swipe on the UIView returned from the query. Currently there are 4 basic directions.
 
 @param query a string containing the DNodi query that will locate the UIView we want to swipe. The swipe will start from the center of that UIView.
 @param swipeDirection a value from SIUISwipeDirection indicting the direction to swipe in.
 @param distance how far to swipe in the given direction.
 @return the swiped view.
 */
-(UIView *) swipeViewWithQuery:(NSString *) query inDirection:(SIUISwipeDirection) swipeDirection forDistance:(int) distance;

#pragma mark - Waiting and holding

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
 @param maxRetrieves hows many times to attempt to find the control before giving up.
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

#pragma mark - Text

/// @name Text

/**
 Ensures that the specified view has focus and then enters the text into it.
 
 @param text the text we want to enter.
 @param view the view to enter the text into.
 */
-(void) enterText:(NSString *) text intoView:(UIView *) view;

/**
 Ensures that the specified view based on a query has focus and then enters the text into it.
 
 @param text the text we want to enter.
 @param query the query that should find the control.
 */
-(void) enterText:(NSString *) text intoViewWithQuery:(NSString *) query;

@end
