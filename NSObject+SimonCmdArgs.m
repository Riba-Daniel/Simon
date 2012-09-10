//
//  NSObject+SimonCmdArgs.m
//  Simon
//
//  Created by Derek Clarkson on 10/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "NSObject+SimonCmdArgs.h"

@interface NSObject (SimonCmdArgs_internal)
-(int) argIndexForName:(NSString *) name;
@end

@implementation NSObject (SimonCmdArgs)

-(BOOL) isArgumentPresentWithName:(NSString *) name {
	return [self argIndexForName:name] != NSNotFound;
}

-(NSString *) argumentValueForName:(NSString *) name {
	
	int index = [self argIndexForName:name];
	NSArray * arguments = [[NSProcessInfo processInfo] arguments];
	
	// return nil if not found or no more arguments.
	if (index == NSNotFound || index + 1 == [arguments count]) {
		return nil;
	}
	
	NSString *argValue = [arguments objectAtIndex:index + 1];
	
	// return nil if the value is actually a flag or argument name.
	if ([argValue characterAtIndex:0] == '-') {
		return nil;
	}
	
	return argValue;
}

-(int) argIndexForName:(NSString *) name {
	NSArray * arguments = [[NSProcessInfo processInfo] arguments];
	__block int argIndex = NSNotFound;
	
	// Get the index of the argument.
	[arguments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([(NSString *) obj isEqualToString:name]) {
			argIndex = (int) idx;
			*stop = YES;
		}
	}];
	
	return argIndex;
	
}

@end
