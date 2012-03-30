//
//  SIAppBackpack.h
//  Simon
//
//  Created by Derek Clarkson on 7/13/11.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIStoryRunner.h"

/**
 This class backpack's on a UIApplication in order to allow Simon to run in the background. You add it through the SIRun macro.
 */
@interface SIAppBackpack : NSObject

/// @name Properties 

/**
 YES by default, this tells Simon to automatically start running stories after the app is ready to receive events. Otherwise Simon's report window is loaded for manual story running.
 */
@property (nonatomic) BOOL autorun;

/// @name Tasks

/**
 Acess to the static story runner.
 */
+(SIStoryRunner *) runner;

@end
