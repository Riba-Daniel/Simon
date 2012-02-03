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
@interface SIAppBackpack : NSObject {
	@private 
}
/// @name Tasks

/**
 Acess to the static story runner.
 */
+(SIStoryRunner *) runner;

@end
