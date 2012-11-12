//
//  StoryRunner.h
//  Simon
//
//  Created by Derek Clarkson on 6/17/11.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Simon/SIStoryAnalyser.h>
#import <Simon/SIRuntime.h>

/**
 SIStoryRunner is the main class used to run stories. 
 */
@interface SIStoryRunner : NSObject

/// @name Properties

/// Contains instances which in turn contain the stories that are part of the run. Setting this controls what stories are run.
@property (nonatomic, retain) SIStoryGroupManager *storyGroupManager;

/// @name Stories

/**
 Executes the passed list of stories. See SIStory for details on how this happens.
 */
-(void) run;

@end
