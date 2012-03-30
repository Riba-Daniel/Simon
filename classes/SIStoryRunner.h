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
#import "SIStoryReporter.h"

/**
 SIStoryRunner is the main class used to run stories. It makes use of a SIStoryFileReader to locate and read in the stories to run, and an instance of a SIRuntime instance to which is used to locate the SIStepMapping instances which provide implmentations for the story steps. Finally it uses a SIStoryReporter instance to provide a report on the results of the run.
 */
@interface SIStoryRunner : NSObject

/// @name Properties

/**
 The reader to source stories from.
 */
@property (retain, nonatomic) SIStoryFileReader * reader;

/**
 The runtime to source mappings from. This is read only.
 */
@property (retain, nonatomic) SIRuntime *runtime;

/**
 After loading this will be populated with the sources of all the stories. This allows access to interrogate them for reporting.
 */
@property (retain, nonatomic) NSArray *storySources;

/**
 After loading this will be populated with the all the stories.
 */
@property (retain, nonatomic) NSArray *stories;

/**
 After loading this will be populated with the all the implementation mappings.
 */
@property (retain, nonatomic) NSArray *mappings;

/// @name Stories

/**
 This was original part of runStories. It was seperated because it allows us to load up a UI for manual running. It's job is to load all the stories
 from the story readers, match them to step implementations and generally get ready to run them.
*/
-(void) loadStories;

/**
 Executes the stories. See SIStory for details on how this happens.
 
 @see SIStory
 */
-(void) runStories;

@end
