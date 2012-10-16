//
//  SIAppBackpackNotifications.h
//  Simon
//
//  Created by Derek Clarkson on 9/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Extension methods for the SIAppBackpack. These methods are internal methods so by defining them here they are not visible on the main interface.
 */
@protocol SIAppBackpackImplementation <NSObject>

/// @name Tasks

/** 
 Called after the app is started and ready for testing. 
 
 @param notification the triggering notification.
 */
-(void) startUp:(NSNotification *) notification;

/**
 Called when the backpack is shutting down.
 
 @param notification the triggering notification.
 */
-(void) shutDown:(NSNotification *) notification;

/**
 Called after a test run has finished.
 
 @param notification the triggering notification.
 */
-(void) runFinished:(NSNotification *) notification;

/**
 Called to indicate that the stories should be run.
 
 @param notification the triggering notification.
 */
-(void) runStories:(NSNotification *) notification;

@end
