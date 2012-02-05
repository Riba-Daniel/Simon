//
//  SIUIUtils.h
//  Simon
//
//  Created by Derek Clarkson on 7/23/11.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Provides tools for accessing the UI of a running application.
 */
@interface SIUIUtils : NSObject

/**
 Executes the given query against the current window to locate one or more UIViews. Given that all interface controls inherit from UIView, this gives us the ability to locate any control on the display.
 
 This maps the xpath to the UI display by using class names of the controls as the xpath node names. 
 
 @param query an xpath as decribed by the dXpath static library.
 */
+(NSArray *) findViewsWithQuery:(NSString *) query;

/**
 Override of findViewsWithQuery:error: which expects to return only a single view.
 This is more strict because it will generate errors if 0 or multiple controls are found instead of the expected control.
 
 @param query an xpath as decribed by the dXpath static library.
 */
+(UIView *) findViewWithQuery:(NSString *) query;


/**
 Simple method which prints a tree view of the current UI to the console.
 */
+(void) logUITree;

/**
 Locates a single UIView based on the passed query and taps at the exact center of that view.
 
 @param query the query that will locate the view. Zero or multiple returns from that query will trigger an error.
 */
+(BOOL) tapViewWithQuery:(NSString *) query;

/**
 Searches for a tab bar and taps the button with the passed label.
 
 @name the text label of the icon we want to tap.
 */
+(void) tapTabBarButtonWithLabel:(NSString *) label;

@end
