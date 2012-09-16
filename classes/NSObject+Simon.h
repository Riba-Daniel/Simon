//
//  NSObject+Simon.h
//  Simon
//
//  Created by Derek Clarkson on 21/03/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Simon/SIJsonAware.h>

/**
 General functions which are called from all sorts of places.
 */
@interface NSObject (Simon)

/**
 This method encapsulates the code which decides whether to run a block directly in the current thread (if it's the main thread) or to sync call it on 
 the main thread. This code is mostly in response to a bug in GHUnit where re-running a test on the details screen will run it on the main thread instead
 of a background thread.
 
 @param block a void block with no parameters which contains the code to be run. Returns values shouldbe handled via __block designated variables.
 */
-(void) executeBlockOnMainThread:(void (^)()) block;

/**
 Excutes the passed block on Simon's thread.
 
 @param block the block to be executed.
 */
-(void) executeOnSimonThread:(void (^)()) block;


@end
