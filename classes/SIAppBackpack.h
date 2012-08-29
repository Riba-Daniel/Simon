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

/// The Queue that Simon uses in the background to execute tasks.
@property (nonatomic, readonly) dispatch_queue_t queue;

/// @name Tasks

/**
 Gets access to the backpack singleton.
 */
+ (SIAppBackpack *)backpack;

/**
 Returns true is the argument was presented to the process.
 
 @param name the name of the argument.
 @return YES if the argument is present.
 */
+(BOOL) isArgumentPresentWithName:(NSString *) name;

/**
 Returns the value associated with the argument presented to the process.
 
 @name name the name of the argument.
 @return the value as a string.
 */
+(NSString *) argumentValueForName:(NSString *) name;

/**
 Exits the app. 
 */
-(void) exit;

@end
