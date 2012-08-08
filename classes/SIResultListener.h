//
//  SIResultListener.h
//  
//
//  Created by Sensis on 8/08/12.
//
//

@interface SIResultListener : NSObject {
    NSUInteger * statusCounts;
}

-(void) storyStarting:(NSNotification *) notification;

-(void) storyExecuted:(NSNotification *) notification;

-(void) runFinished:(NSNotification *) notification;

@end
