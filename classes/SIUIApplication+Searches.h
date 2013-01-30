//
//  SIUIApplication+Searches.h
//  Simon
//
//  Created by Derek Clarkson on 4/01/13.
//  Copyright (c) 2013 Sensis. All rights reserved.
//

#import <Simon/SIUIApplication.h>

/**
 Category of methods for finding things on the UI.
*/

@interface SIUIApplication (Searches)

/** @name Finding things */

/**
 Executes the given query against the current window to locate one or more UIViews. Given that all interface controls inherit from UIView, this gives us the ability to locate any control on the display.
 
 This maps the xpath to the UI display by using class names of the controls as the xpath node names.
 
 @param query a path as decribed by the dNodi static library.
 */
-(NSArray *) viewsWithQuery:(NSString *) query;

/**
 Override of findViewsWithQuery: which expects to return only a single view.
 This is more strict because it will generate errors if 0 or multiple controls are found instead of the expected control.
 
 @param query a dNodi path which should lead to the desired UIView.
 */
-(UIView *) viewWithQuery:(NSString *) query;

/**
 Looks for a specific view. If it's not found it will periodically retry until the timeout value is reached.
 This is more strict because it will generate errors if 0 or multiple controls are found instead of the expected control.
 
 @param query a dNodi path which should lead to the desired UIView.
 @param timeout an NSTimeInterval which specifies the maximum wait time. This method will periodically scan the interface for the requested view and after the number of specified seconds, will generate a not found error.
 */
-(UIView *) viewWithQuery:(NSString *) query timeout:(NSTimeInterval) timeout;

/**
 Finds a view with the specified tag value.
 
 @param tag the NSInteger tag value which identifies the view to return.
 */
-(UIView *) viewWithTag:(NSInteger) tag;

/**
 Finds a view with the specified tag value.
 
 @param tag the NSInteger tag value which identifies the view to return.
 @param timeout an NSTimeInterval which specifies the maximum wait time. This method will periodically scan the interface for the requested view and after the number of specified seconds, will generate a not found error.
 */
-(UIView *) viewWithTag:(NSInteger) tag timeout:(NSTimeInterval) timeout;

/**
 returns YES if the query returns one or more UIViews.
 
 @param query a dNodi path which should lead to the desired UIView.
 */
-(BOOL) isViewPresent:(NSString *) query;

/**
 returns YES if the query returns one or more UIViews.
 
 @param query a dNodi path which should lead to the desired UIView.
 @param view a reference to a variable of type UIView*. If the view is found, this variable will be set to point to the view.
 */
-(BOOL) isViewPresent:(NSString *) query view:(UIView **) view;

/**
 Locates a button with the specific label. 
 
 @param label the label to look for.
 */
-(UIButton *) buttonWithLabel:(NSString *) label;

/**
 Locates a button with the specific label. 
 
 @param label the label to look for.
 @param timeout an NSTimeInterval which specifies the maximum wait time. This method will periodically scan the interface for the requested view and after the number of specified seconds, will generate a not found error.
 */
-(UIButton *) buttonWithLabel:(NSString *) label timeout:(NSTimeInterval) timeout;

/**
 Locates a button with the specific label.
 
 @param label the label to look for.
 */
-(UIView *) tabBarButtonWithLabel:(NSString *) label;

/**
 Locates a tab bar item with the specific label. 
 
 @param label the label to look for.
 @param timeout an NSTimeInterval which specifies the maximum wait time. This method will periodically scan the interface for the requested view and after the number of specified seconds, will generate a not found error.
 */
-(UIView *) tabBarButtonWithLabel:(NSString *) label timeout:(NSTimeInterval) timeout;

@end
