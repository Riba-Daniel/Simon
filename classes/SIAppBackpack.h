//
//  SIAppBackpack.h
//  Simon
//
//  Created by Derek Clarkson on 7/13/11.
//  Copyright 2011 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This class backpack's on a UIApplication in order to allow Simon to run in the background. You add it through the SIRun macro.
 */
@interface SIAppBackpack : NSObject {
	@private 
	NSString * fileName;
}
/// @name Initialisation

/**
 This init allows you to pass in a single story file rathe than having Simon scanning for all story files. This is most useful when debugging.
 
 @param aFileName the .stories file you want to run.
 */
-(id) initWithStoryFile:(NSString *) aFileName;

@end
