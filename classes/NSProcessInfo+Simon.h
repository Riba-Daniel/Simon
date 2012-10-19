//
//  NSObject+SimonCmdArgs.h
//  Simon
//
//  Created by Derek Clarkson on 10/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Methods for dealing with arguments passed on the command line.
 */
@interface NSProcessInfo (Simon)

/// @name Command line arguments

/**
 Returns the index of the specified argument.
 
 @param name the name of the argument.
 @return a zero based index of where the argument appears in the argument list. NSNotFound if the argument is not present.
 */
-(NSInteger) argIndexForName:(NSString *) name;

/**
 Returns true if the argument was presented to the process.
 
 @param name the name of the argument.
 @return YES if the argument is present.
 */
-(BOOL) isArgumentPresentWithName:(NSString *) name;

/**
 Returns the value associated with the argument presented to the process.
 
 @param name the name of the argument.
 @return the value as a string.
 */
-(NSString *) argumentValueForName:(NSString *) name;

@end
