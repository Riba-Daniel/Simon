//
//  SIAppBackpack.h
//  Simon
//
//  Created by Derek Clarkson on 7/13/11.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SIStoryRunner.h"
#import "SIState.h"
#import "SIStoryLogger.h"
#import "SIAppBackpackImplementation.h"
#import "SIStorySources.h"
#import "SIStoryFileReader.h"

/**
 This class backpack's on a UIApplication in order to allow Simon to run in the background. You add it through the SIRun macro.
 */
@interface SIAppBackpack : NSObject<SIAppBackpackImplementation> 

/// @name Properties

/// The current state of Simon.
@property (nonatomic, readonly) SIState *state;

/// Readonly reference to the story sources.
@property (nonatomic, readonly) SIStorySources *storySources;

/// Readonly reference to the list of loaded SIStepMapping instances.
@property (nonatomic, readonly) NSArray *mappings;

/// The file reader to read story files with.
@property (nonatomic, retain) SIStoryFileReader *reader;

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

@end
