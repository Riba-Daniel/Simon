//
//  SIAppBackpack.h
//  Simon
//
//  Created by Derek Clarkson on 7/13/11.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SimonHttpServer/HTTPServer.h>

#import "SIStoryRunner.h"
#import "SIUIReportManager.h"
#import "SIState.h"
#import "SIStoryLogReporter.h"

/**
 This class backpack's on a UIApplication in order to allow Simon to run in the background. You add it through the SIRun macro.
 */
@interface SIAppBackpack : NSObject {
@private
	SIUIReportManager *ui;
	SIStoryRunner *runner;
	HTTPServer *server;
	SIStoryLogReporter *logger;
}

/// @name Properties 

/// The current state of Simon.
@property (nonatomic, retain) SIState *state;

/// Readonly reference to the story sources.
@property (nonatomic, readonly) NSArray *storySources;

/// Readonly reference to the list of loaded SIStepMapping instances.
@property (nonatomic, readonly) NSArray *mappings;

/// @name Tasks

/**
 Gets access to the backpack singleton.
 */
+ (SIAppBackpack *)backpack;

/**
 Used by the HTTP server to execute all the stories.
 */
- (void) runAllStories;

/**
 Returns true is the argument was presented to the process.
 
@name name the name of the argument.
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
