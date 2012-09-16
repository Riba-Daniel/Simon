//
//  SIAppBackpack.h
//  Simon
//
//  Created by Derek Clarkson on 7/13/11.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Simon/SIStoryRunner.h>
#import <Simon/SIStoryLogger.h>
#import <Simon/SIAppBackpackImplementation.h>
#import <Simon/SIStorySources.h>
#import <Simon/SIStoryFileReader.h>

/**
 This class backpack's on a UIApplication in order to allow Simon to run in the background. You add it through the SIRun macro.
 */
@interface SIAppBackpack : NSObject<SIAppBackpackImplementation> 

/// @name Properties

/// Readonly reference to the story sources.
@property (nonatomic, readonly) SIStorySources *storySources;

/// Readonly reference to the list of loaded SIStepMapping instances.
@property (nonatomic, readonly) NSArray *mappings;

/// The file reader to read story files with.
@property (nonatomic, retain) SIStoryFileReader *reader;

/// The story runner which will execute the stories.
@property (nonatomic, readonly) SIStoryRunner *runner;

/// The Queue that Simon uses in the background to execute tasks. Normally this is not set, except for testing purposes.
@property (nonatomic, assign) dispatch_queue_t queue;

/// @name Tasks

/**
 Gets access to the backpack singleton.
 */
+ (SIAppBackpack *)backpack;

/**
 Mainly used for testing purposes.
 
 @param backpack the instance of SIAppBackpack to be used.
 */
+ (void) setBackpack:(SIAppBackpack *) backpack;

/// Called once startup has finished. A good place to add code.
-(void) startUpFinished;

/**
 Exits the app. 
 */
-(void) exit;

@end
