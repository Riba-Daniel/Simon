//
//  SIAppBackpackNotifications.h
//  Simon
//
//  Created by Derek Clarkson on 9/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Extension methods for the SIAppBackpacks
 */
@protocol SIAppBackpackImplementation <NSObject>

@property (nonatomic, readonly) SIStoryRunner *runner;

-(void) startUp:(NSNotification *) notification;
-(void) shutDown:(NSNotification *) notification;
-(void) runFinished:(NSNotification *) notification;
-(void) runStories:(NSNotification *) notification;

/**
 Excutes the passed block on Simon's thread.
 */
-(void) executeOnSimonThread:(void (^)()) block;

@end
