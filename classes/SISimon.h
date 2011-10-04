//
//  Simon.h
//  Simon
//
//  Created by Derek Clarkson on 6/18/11.
//  Copyright 2011. All rights reserved.
//
#import <dUsefulStuff/DCCommon.h>
#import <objc/runtime.h>

#import "SIStepMapping.h"
#import "SIStory.h"
#import "SIInternal.h"
#import "SIAppBackpack.h"
#import "SIUIUtils.h"
#import "SIUIViewHandler.h"
#import "SIUIHandlerFactory.h"
#import "UIView+Simon.h"

#pragma mark - Runners

/**
 This macro must be placed in your startup code. It loads Simon into the background and automatically runs the stories once the application is active and ready.
 If you want a particular story file to be run, just enter it's name as a parameter.
 */
#ifdef DC_DEBUG

#define SIRun() \
	SIAppBackpack *backpack = [[[SIAppBackpack alloc] init] autorelease]; \
	DC_LOG(@"Started backpack %@", [backpack description]);

#define SIRunFile(storyFile) \
	SIAppBackpack *backpack = [[[SIAppBackpack alloc] initWithStoryFile:storyFile] autorelease]; \
	DC_LOG(@"Started backpack %@", [backpack description]);

#else

#define SIRun() [[[SIAppBackpack alloc] init] autorelease];
#define SIRunFile(storyFile) [[[SIAppBackpack alloc] initWithStoryFile:storyFile] autorelease];

#endif


#pragma mark - Step mapping

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

#pragma mark - Storing data

/**
 * Macro which stores data in the story so it can be passed between implmentation classes. 
 */
#define SIStoreInStory(key, value) [(SIStory *) objc_getAssociatedObject(self, SIINSTANCE_STORY_REF_KEY) storeObject:value withKey:key]

/**
 * The opposite of SISToreInStory(key, value) this macro retrieves a previously stored value.
 */
#define SIRetrieveFromStory(key) [(SIStory *) objc_getAssociatedObject(self, SIINSTANCE_STORY_REF_KEY) retrieveObjectWithKey:key]

#pragma mark - Accessing the UI
/// @name UI interactions

/**
 Prints a tree view of the current window's UIView hirachy to the console. This is very useful for debugging and working out queries to location controls. 
 */
#define SIPrintCurrentWindowTree() [SIUIUtils logUITree]

/**
 Simple wrapper around dNodi's query facilities which returns a simple object from the display. This will trigger an error if the control is not found, so it is both a find and assert in one wrapper. 
 
 @param path a NSString containing the path to follow.
 @param error a reference to a pointer to a NSError variable. (**NSError).
 @return a single UIView instance or nil if there was an error.
 */
#define SIFindView(path, errorRef) [SIUIUtils findViewWithQuery:path error:errorRef]

/**
 Finds and returns an array of views. This does not assert anything about the views it is looking for.

 @param path a NSString containing the path to follow.
 @param error a reference to a pointer to a NSError variable. (**NSError).
 @return a NSArray containing the found views, or nil if there was an error.
 */
#define SIFindViews(path, errorRef) [SIUIUtils findViewsWithQuery:path error:errorRef]

/**
 Finds the control specified by the path and taps it. How this tap in implemented is very dependent on the control as some controls are dificult to synthensize a tap for.
 */
#define SITapControl(path, errorRef) \
	do { \
		UIView<DNNode> *theView = SIFindView(path, errorRef); \
		SIUIViewHandler *handler = [[SIUIHandlerFactory handlerFactory] createHandlerForView: theView]; \
		[handler tap]; \
	} while (NO);

#pragma mark - Test assertions

/// @name Assertions

// These are sourced from Apple's Sent Kit and the GHUnit macros. They are then modified to work independantly of a testing framework. 

/*! Generates a failure unconditionally. 
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present
 @param ... A variable number of arguments to the format string. Can be absent
 */
#define SIFail(description, ...) \
do { \
	NSLog(@"Throwing exception"); \
	NSString *_message = @""; \
	if (description) { \
		_message = [NSString stringWithFormat:description, ##__VA_ARGS__]; \
		NSLog(@"MESSAGE %@", _message); \
	} \
	[SIStepMapping cacheException:[NSException exceptionWithName:@"SIAssertionException" reason:_message userInfo:nil]]; \
} while (NO);
//@throw [NSException exceptionWithName:@"SIAssertionException" reason:_message userInfo:nil]; \


