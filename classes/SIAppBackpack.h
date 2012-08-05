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

#define ARG_NO_LOAD @"--no-load"
#define ARG_SHOW_UI @"--ui"
#define ARG_NO_AUTORUN @"--no-autorun"

/**
 This class backpack's on a UIApplication in order to allow Simon to run in the background. You add it through the SIRun macro.
 */
@interface SIAppBackpack : NSObject {
@private
	SIUIReportManager *ui;
	SIStoryRunner *runner;
	HTTPServer *server;
}

/// @name Properties 

/// @name Tasks

/**
 Gets access to the backpack singleton.
 */
+ (SIAppBackpack *)backpack;

/**
 Used by the HTTP server to execute all the stories.
 */
- (void) runAllStories;

@end
