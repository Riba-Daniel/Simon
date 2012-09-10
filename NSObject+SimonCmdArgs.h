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
@interface NSObject (SimonCmdArgs)
/**
 Returns true is the argument was presented to the process.
 
 @param name the name of the argument.
 @return YES if the argument is present.
 */
-(BOOL) isArgumentPresentWithName:(NSString *) name;

/**
 Returns the value associated with the argument presented to the process.
 
 @name name the name of the argument.
 @return the value as a string.
 */
-(NSString *) argumentValueForName:(NSString *) name;

@end
