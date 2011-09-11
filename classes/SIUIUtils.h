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
 
 @param xpath an xpath as decribed by the dXpath static library.
 @param error a pointer to an error variable that can be populated if there is a problem.
 */
+(NSArray *) findViewsWithQuery:(NSString *) query error:(NSError **) error;

/**
 Override of findViewsWithQuery:error: which expects to return only a single view.
 This is more strict because it will generate errors if 0 or multiple controls are found instead of the expected control.
 
 @param xpath an xpath as decribed by the dXpath static library.
 @param error a pointer to an error variable that can be populated if there is a problem.
 */
+(UIView *) findViewWithQuery:(NSString *) query error:(NSError **) error;


/**
 Simple method which prints a tree view of the current UI to the console.
 */
+(void) logUITree;

@end
