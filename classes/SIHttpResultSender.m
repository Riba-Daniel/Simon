//
//  SIHttpResultSender.m
//  Simon
//
//  Created by Derek Clarkson on 9/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Simon/SIHttpResultSender.h>

/**
 The intent of this class is to be used to notify listening command line programs of the results of story runs.
 */
@implementation SIHttpResultSender

-(void) runStarting:(NSNotification *) notification {
	[super runStarting:notification];
	// DO something http'y
}

-(void) storyStarting:(NSNotification *) notification {
	[super storyStarting:notification];
	// DO something http'y
}

-(void) storyExecuted:(NSNotification *) notification {
	[super storyExecuted:notification];
	// DO something http'y
}

-(void) runFinished:(NSNotification *) notification {
	[super runFinished:notification];
	// DO something http'y
}

@end
