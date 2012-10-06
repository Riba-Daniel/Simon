//
//  NSProcessInfo+Simon.m
//  Simon
//
//  Created by Derek Clarkson on 10/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "NSProcessInfo+Simon.h"

@implementation NSObject (SimonCmdArgs)

-(BOOL) isArgumentPresentWithName:(NSString *) name {
	return [self argIndexForName:name] != NSNotFound;
}

-(NSString *) argumentValueForName:(NSString *) name {
	
	NSInteger index = [self argIndexForName:name];
	NSUInteger nextIndex = (NSUInteger)index + 1;
	NSArray * arguments = [[NSProcessInfo processInfo] arguments];
	
	// return nil if not found or no more arguments.
	if (index == NSNotFound || nextIndex == [arguments count]) {
		return nil;
	}
	
	NSString *argValue = [arguments objectAtIndex:nextIndex];
	
	// return nil if the value is actually a flag or argument name.
	if ([argValue characterAtIndex:0] == '-') {
		return nil;
	}
	
	return argValue;
}

-(NSInteger) argIndexForName:(NSString *) name {
	NSArray * arguments = [[NSProcessInfo processInfo] arguments];
	__block NSInteger argIndex = NSNotFound;
	
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
