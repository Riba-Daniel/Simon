//
//  SIUIApplication+Text.h
//  Simon
//
//  Created by Derek Clarkson on 4/01/13.
//  Copyright (c) 2013 Sensis. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Simon/SIUIApplication.h>

/**
 Category of text entry methods.
 */

@interface SIUIApplication (Text)

/// @name Text

/**
 Ensures that the specified view has focus and then enters the text into it.
 
 @param text the text we want to enter.
 @param view the view to enter the text into.
 */
-(void) enterText:(NSString *) text intoView:(UIView *) view;

@end
