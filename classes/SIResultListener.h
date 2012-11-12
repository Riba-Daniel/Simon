//
//  SIResultListener.h
//  
//
//  Created by on 8/08/12.
//
//

#import <Simon/SIConstants.h>

/**
 Instances of this class will automatically listen to status notifications and respond according to the intent of the class.
 */
@interface SIResultListener : NSObject

/** 
 Called when a story is about to be executed. If overridden, super should be called to ensure that the result data structures are built correctly.
 
 @param notification the notification containing userInfo data which refers to the SIStory and SIStoryGroup.
 */
-(void) storyStarting:(NSNotification *) notification;

/**
 Called when a story has finished executing. If overridden, super should be called to ensure that the result data structures are built correctly.
 
 @param notification the notification containing userInfo data which refers to the SIStory and SIStoryGroup.
 */
-(void) storyExecuted:(NSNotification *) notification;

/**
 Called before all the stories have been executed. If overridden, super should be called to ensure that the result data structures are built correctly.
 
 @param notification the notification.
 */
-(void) runStarting:(NSNotification *) notification;

/**
 Called when all the stories have been executed. If overridden, super should be called to ensure that the result data structures are built correctly.
 
 @param notification the notification.
 */
-(void) runFinished:(NSNotification *) notification;

/**
 Returns the list of stories that executed with a result of the passed status. These stories will be compiled from all the stories executed in the run.
 
 @param status the status whose list of stories we want.
 @return a NSArray populated with the stories.
 */
-(NSArray *) storiesWithStatus:(SIStoryStatus) status;

@end
