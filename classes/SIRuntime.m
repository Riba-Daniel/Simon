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
   
   // Redirect to the main thread.
   if (![NSThread isMainThread]) {
      if (![[NSThread currentThread] isMainThread]) {
         DC_LOG(@"Redirecting to main thread via GCD");
         dispatch_queue_t mainQueue = dispatch_get_main_queue();
         __block NSArray *results = nil;
         dispatch_sync(mainQueue, ^{
            results = [self allMappingMethodsInRuntime];
         });
         return results;
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
		
      NSBundle *mainBundle = [NSBundle mainBundle];
      mainBundle 
      NSBundle * classBundle;
      Class nextClass;
		for (int index = 0; index < numClasses; index++) {
			
         nextClass = classes[index];
			
			if (nextClass == NULL || nextClass == nil || class_isMetaClass(nextClass)) {
				DC_LOG(@"%i: NULL/nil/MetaClass class returned, skipping");
				continue;
			}
			
			// Ignore if the class does not belong to the application bundle.
			DC_LOG(@"%i: Checking class: %@", index, NSStringFromClass(nextClass));
			classBundle = [NSBundle bundleForClass:nextClass];
			if (![mainBundle isEqual: classBundle]) {
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
			DC_LOG(@"\tStep method found %@ %@", NSStringFromClass(class), NSStringFromSelector(sel));
			id returnValue = objc_msgSend(class, sel, class);
			[array addObject:returnValue];
			methodsFound = YES;
		}
	}
	
	return methodsFound;
}

@end
