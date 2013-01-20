//
//  SIUIApplication.h
//  Simon
//
//  Created by Derek Clarkson on 7/23/11.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Simon/SIUIConstants.h>
#import <Simon/SIUIViewHandlerFactory.h>
#import <Simon/SIUIViewDescriptionVisitorDelegate.h>

/**
 Provides tools for accessing the UI of a running application.
 */
@interface SIUIApplication : NSObject<SIUIViewDescriptionVisitorDelegate> 

-(SIUIViewHandler *) viewHandlerForView:(UIView *) view;

/// @name Properties

/// Factory which is used to generate view handlers for talking to UIView objects returned from queries. You can set this to a custom factory for implementing your own view handlers.
@property (retain, nonatomic) SIUIViewHandlerFactory *viewHandlerFactory;

/// If set to YES, disables the auto correction of entered text via the keyboard when using the enterText:intoField: method. This is useful for testing.
@property (nonatomic) BOOL disableKeyboardAutocorrect;

/// If set to YES (Default) Simon will print each action is is asked to do to the log. The intent of this is to help with debugging apps when a story fails.
@property (nonatomic, getter=isLogActions) BOOL logActions;

// How often the code will retry when looking for something in the UI and not finding it. This is the time interval in seconds between each attempt to find the target object.
@property (nonatomic, assign) NSTimeInterval retryFrequency;

// The maximum number of seconds to keep looking for something before timing out and assuming that the test will fail. Search methods such as viewWithQuery use this as the default timeout value which they then pass to other methods such as viewWithQuery:timeout:
@property (nonatomic, assign) NSTimeInterval timeout;

#pragma mark - Accessors

/** @name Singleton accessors */

/**
 Accesses the SIUIApplication singleton.
 */
+(SIUIApplication *) application;

#pragma mark - Logging

/// @name Logging

/**
 Simple method which prints a tree view of the current UI to the console.
 */
-(void) logUITree;

@end
