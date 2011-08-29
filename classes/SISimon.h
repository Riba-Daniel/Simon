//
//  Simon.h
//  Simon
//
//  Created by Derek Clarkson on 6/18/11.
//  Copyright 2011 Sensis. All rights reserved.
//
#import <dUsefulStuff/DCCommon.h>
#import <objc/runtime.h>

#import "SIStepMapping.h"
#import "SIStory.h"
#import "SIInternal.h"
#import "SIAppBackpack.h"
#import "SIUIUtils.h"

/**
 This macro must be placed in your startup code. It loads Simon into the background and automatically runs the stories once the application is active and ready.
 If you want a particular story file to be run, just enter it's name as a parameter.
 */
#define SIRun() \
	SIAppBackpack *backpack = [[SIAppBackpack alloc] init]; \
	DC_LOG(@"Started backpack %@", [backpack description]);

#define SIRunFile(storyFile) \
	SIAppBackpack *backpack = [[SIAppBackpack alloc] initWithStoryFile:storyFile]; \
	DC_LOG(@"Started backpack %@", [backpack description]);

/**
 This macro maps a regex to a selector in the current class. Simon expects that the order and type of any groups in the regex will
 match the order and types of arguments in the selector. So we recommend that the this is used before the selector like this
 `
 SIMapStepToSelector(@"", thisIsMyMethod:)
 -(void) thisIsMyMethod:(NSString *) stringValue {
    ...
 }
 `
 */
#define SIMapStepToSelector(theRegex, aSelector) \
+(SIStepMapping *) DC_CONCATINATE(SISTEP_METHOD_PREFIX, __LINE__):(Class) class { \
	DC_LOG(@"Creating mapping \"%@\" -> %@::%@", theRegex, NSStringFromClass(class), toNSString(aSelector)); \
	NSError *error = nil; \
	SIStepMapping *mapping = [SIStepMapping stepMappingWithClass:class selector:@selector(aSelector) regex:theRegex error:&error]; \
	if (mapping == nil) { \
		@throw [NSException exceptionWithName:@"SIMappingException" reason:error.localizedDescription userInfo:error.userInfo]; \
	} \
   return mapping; \
}

/**
 * Macro which stores data in the story so it can be passed between implmentation classes. 
 */
#define SIStoreInStory(key, value) [(SIStory *) objc_getAssociatedObject(self, SIINSTANCE_STORY_REF_KEY) storeObject:value withKey:key]

/**
 * The opposite of SISToreInStory(key, value) this macro retrieves a previously stored value.
 */
#define SIRetrieveFromStory(key) [(SIStory *) objc_getAssociatedObject(self, SIINSTANCE_STORY_REF_KEY) retrieveObjectWithKey:key]

/// @name UI interactions

/**
 Prints a tree view of the current window's UIView hirachy to the console. This is very useful for debugging and working out queries to location controls. 
 */
#define SIPrintCurrentWindowTree() [SIUIUtils logUITree]

/**
 Simple wrapper around dNodi's query facilities which returns a simple object from the display. This will trigger an error if the control is not found, so it is both a 
 find and assert in one wrapper. 
 */
#define SIFindView(path)

/**
 Finds and returns an array of views. This does not assert anything about the views it is looking form.
 */
#define SIFindViews(path)

/**
 Finds the control specified by the path and taps it. How this tap in implemented is very dependent on the control as some controls are dificult to synthensize a tap for.
 */
#define SITapControl(path) 



