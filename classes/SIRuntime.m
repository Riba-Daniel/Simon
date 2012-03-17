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
-(void) addMappingMethodsFromClass:(Class) class toArray:(NSMutableArray *) array;
-(Class) getUltimateSuperClass:(Class) class; 
@end

@implementation SIRuntime

-(NSArray *) allMappingMethodsInRuntime {
   
   // Redirect to the main thread.
   if (![NSThread isMainThread]) {
      if (![[NSThread currentThread] isMainThread]) {
         DC_LOG(@"Redirecting to main thread via GCD");
         dispatch_queue_t mainQueue = dispatch_get_main_queue();
         __block NSArray *results = nil;
         dispatch_sync(mainQueue, ^{
				// retain so we don't get random EXEC_BAD_ACCESS's.
            results = [[self allMappingMethodsInRuntime] retain];
         });
         
         // return with autorelease.
         return [results autorelease];
      }
   }
	
	int numClasses = objc_getClassList(NULL, 0);
	DC_LOG(@"Found %i classes in runtime", numClasses);
	
	NSMutableArray * stepMappings = [[[NSMutableArray alloc] init] autorelease];
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
         
         // Check to see where it comes from.
         superClass = [self getUltimateSuperClass:nextClass];
         if (nextClass == superClass || superClass != [NSObject class]) {
            continue;
         }
			
			// Ignore if the class does not belong to the application bundle.
			classBundle = [NSBundle bundleForClass:nextClass];
			if (![classBundle isEqual:mainBundle]) {
				continue;
			}
			
			// Now locate the mapping methods.
			[self addMappingMethodsFromClass:nextClass toArray:stepMappings];
			
		}
		
		free(classes);
	}
	
	return stepMappings;
	
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
	for (size_t j = 0; j < methodCount; ++j) {
		
      currMethod = methods[j];
      sel = method_getName(currMethod);	
      
		if ([NSStringFromSelector(sel) hasPrefix:prefix]) {
			DC_LOG(@"\tStep method found %@::%@", NSStringFromClass(class), NSStringFromSelector(sel));
         returnValue = objc_msgSend(class, sel, class);
			[array addObject:returnValue];
		}
	}
}

@end
