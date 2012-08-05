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
#import <Simon-core/NSObject+Simon.h>

@interface SIRuntime()
-(void) addMappingMethodsFromClass:(Class) class toArray:(NSMutableArray *) array;
-(Class) getUltimateSuperClass:(Class) class; 
@end

@implementation SIRuntime

-(NSArray *) allMappingMethodsInRuntime {
   
	__block NSMutableArray *stepMappings = nil;
	
	[self executeBlockOnMainThread:^{

		int numClasses = objc_getClassList(NULL, 0);
		DC_LOG(@"Found %i classes in runtime", numClasses);
		
		stepMappings = [[NSMutableArray alloc] init];
		if (numClasses > 0 ) {
			
			Class * classes = malloc(sizeof(Class) * numClasses);
			// Don't use the return number from this call because it's often wrong. Reported as a Bug to Apple.
			objc_getClassList(classes, numClasses);
			DC_LOG(@"When returning classes, %i classes in runtime", numClasses);
			
			Class nextClass;
			Class superClass;
			NSBundle * classBundle;
			NSBundle *mainBundle = [NSBundle mainBundle];
			for (int index = 0; index < numClasses; index++) {
				
				nextClass = classes[index];
				
				// Ignore nulls.
				if (nextClass == NULL 
					 || nextClass == nil) {
					continue;
				}

				// Ignore if the class does not belong to the application bundle.
				classBundle = [NSBundle bundleForClass:nextClass];
				if (![classBundle isEqual:mainBundle]) {
					continue;
				}
				
				// Check to see where it comes from.
				superClass = [self getUltimateSuperClass:nextClass];
				if (nextClass == superClass || superClass != [NSObject class]) {
					continue;
				}
				
				// Now locate the mapping methods.
				[self addMappingMethodsFromClass:nextClass toArray:stepMappings];
				
			}
			
			free(classes);
		}
	}];
	
	return [stepMappings autorelease];
	
}

-(Class) getUltimateSuperClass:(Class) class {
   Class parent = class_getSuperclass(class);
   return parent == nil ? class : [self getUltimateSuperClass:parent];
}


-(void) addMappingMethodsFromClass:(Class) class toArray:(NSMutableArray *) array {
   
	// Get the class methods. To get instance methods, drop the object_getClass function.
	unsigned int methodCount;
	Method *methods = class_copyMethodList(object_getClass(class), &methodCount);
	
	// This handles disposing of the method memory for us even if an exception is thrown. 
	[NSData dataWithBytesNoCopy:methods length:sizeof(Method) * methodCount];
	
	// Search the methods for mapping methods. If found, execute them to retrieve the 
	// mapping objects and add to the return array.
	NSString  * prefix = toNSString(SI_STEP_METHOD_PREFIX);
   Method currMethod;
   SEL sel;
   id returnValue;
	for (size_t idx = 0; idx < methodCount; ++idx) {
		
      currMethod = methods[idx];
      sel = method_getName(currMethod);	
      
		if ([NSStringFromSelector(sel) hasPrefix:prefix]) {
			DC_LOG(@"\tStep method found %@::%@", NSStringFromClass(class), NSStringFromSelector(sel));
         returnValue = objc_msgSend(class, sel, class);
			[array addObject:returnValue];
		}
	}
}

@end
