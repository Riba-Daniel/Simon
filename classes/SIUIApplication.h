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

/**
 Provides tools for accessing the UI of a running application.
 */
@interface SIUIApplication : NSObject

/// @name Properties

/// Factory which is used to generate view handlers for talking to UIView objects returned from queries. You can set this to a custom factory for implementing your own view handlers.
@property (retain, nonatomic) SIUIViewHandlerFactory *viewHandlerFactory;

#pragma mark - Accessors
/// @name Singleton Accessors

/**
 Accesses the SIUIApplication singleton.
 */
+(SIUIApplication *) application;

#pragma mark - Finding

/// @name Finding things

/**
 Executes the given query against the current window to locate one or more UIViews. Given that all interface controls inherit from UIView, this gives us the ability to locate any control on the display.
 
 This maps the xpath to the UI display by using class names of the controls as the xpath node names. 
 
 @param query an xpath as decribed by the dXpath static library.
 */
-(NSArray *) findViewsWithQuery:(NSString *) query;

/**
 Override of findViewsWithQuery:error: which expects to return only a single view.
 This is more strict because it will generate errors if 0 or multiple controls are found instead of the expected control.
 
 @param query an xpath as decribed by the dXpath static library.
 */
-(UIView *) findViewWithQuery:(NSString *) query;

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
 */
-(void) tapViewWithQuery:(NSString *) query;

/**
 Searches for a button with a specific label taps it.
 
 @param label the text label of the icon we want to tap.
 */
-(void) tapButtonWithLabel:(NSString *) label;

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
 Performs a swipe on the specified control.
 
 @param query a string containing the DNodi query that will locate the control we want to swipe. The swipe will start from the center of that control.
 @param swipeDirection a value from SIUISwipeDirection indicting the direction to swipe in.
 @param distance how far to swipe in the given direction.
 */
-(void) swipeViewWithQuery:(NSString *) query inDirection:(SIUISwipeDirection) swipeDirection forDistance:(int) distance;

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

@end
