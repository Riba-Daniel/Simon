//
//  SIRuntime.m
//  Simon
//
//  Created by Derek Clarkson on 6/20/11.
//  Copyright 2011. All rights reserved.
//
#import <dUsefulStuff/DCCommon.h>
#import <objc/message.h>

#import "SISimon.h"
#import "SIRuntime.h"

@interface SIRuntime()
-(BOOL) addMappingMethodsFromClass:(Class) class toArray:(NSMutableArray *) array;
@end

@implementation SIRuntime

-(NSArray *) allMappingMethodsInRuntime {
	
	int numClasses = objc_getClassList(NULL, 0);
	SI_LOG(@"Found %i classes in runtime", numClasses);
	
	NSMutableArray * stepMappings = [[[NSMutableArray alloc] init] autorelease];
	if (numClasses > 0 ) {
		
		Class * classes = malloc(sizeof(Class) * numClasses);
		// Don't use the return number from this call because it's often wrong. Reported as a Bug to Apple.
		objc_getClassList(classes, numClasses);
		SI_LOG(@"When returning classes, %i classes in runtime", numClasses);
		
		for (int index = 0; index < numClasses; index++) {
			
			Class nextClass = classes[index];
			
			if (nextClass == NULL || nextClass == nil) {
				SI_LOG(@"%i: NULL/nil class returned, skipping");
				continue;
			}
			
			// Ignore if the class does not belong to the application bundle.
			SI_LOG(@"%i: Checking class: %@", index, NSStringFromClass(nextClass));
			NSBundle * classBundle = [NSBundle bundleForClass:nextClass];
			if ([NSBundle mainBundle] != classBundle) {
				continue;
			}
			
			// Now locate the mapping methods.
			[self addMappingMethodsFromClass:nextClass toArray:stepMappings];
			
		}
		
		free(classes);
	}
	
	return stepMappings;
	
}

-(BOOL) addMappingMethodsFromClass:(Class) class toArray:(NSMutableArray *) array {

	// Get the class methods. To get instance methods, drop the object_getClass function.
	unsigned int methodCount;
	Method *methods = class_copyMethodList(object_getClass(class), &methodCount);
	
	// This handles disposing of the method memory for us even if an exception is thrown. 
	[NSData dataWithBytesNoCopy:methods
								length:sizeof(Method) * methodCount];
	
	// Search the methods for mapping methods. If found, execute them to retrieve the 
	// mapping objects and add to the return array.
	NSString  * prefix = toNSString(SI_STEP_METHOD_PREFIX);
	BOOL methodsFound = NO;
	for (size_t j = 0; j < methodCount; ++j) {
		
		Method currMethod = methods[j];
		SEL sel = method_getName(currMethod);	

		if ([NSStringFromSelector(sel) hasPrefix:prefix]) {
			SI_LOG(@"\tStep method found %@ %@", NSStringFromClass(class), NSStringFromSelector(sel));
			id returnValue = objc_msgSend(class, sel, class);
			[array addObject:returnValue];
			methodsFound = YES;
		}
	}
	
	return methodsFound;
}

@end
