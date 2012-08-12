//
//  StoryRunner.h
//  Simon
//
//  Created by Derek Clarkson on 6/17/11.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIStoryFileReader.h"
#import "SIRuntime.h"

/**
 SIStoryRunner is the main class used to run stories. 
 */
@interface SIStoryRunner : NSObject

/// @name Properties
@property (nonatomic, retain) SIStorySources *storySources;

/// @name Stories

/**
 Executes the passed list of stories. See SIStory for details on how this happens.
 */
-(void) run;

@end
