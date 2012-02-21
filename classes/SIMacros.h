//
//  SIMacros.h
//  Simon
//
//  Created by Derek Clarkson on 7/1/11.
//  Copyright 2011. All rights reserved.
//
#import <dUsefulStuff/DCCommon.h>

#pragma mark - Runners

/**
 This macro must be placed in your startup code. It loads Simon into the background and automatically runs the stories once the application is active and ready.
 If you want a particular story file to be run, just enter it's name as a parameter.
 */
#ifdef SI_DEBUG

#define SIRun() \
SIAppBackpack *backpack = [[[SIAppBackpack alloc] init] autorelease]; \
DC_LOG(@"Started backpack %@", [backpack description]);

#else

#define SIRun() [[[SIAppBackpack alloc] init] autorelease];

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
+(SIStepMapping *) DC_CONCATINATE(SI_STEP_METHOD_PREFIX, __LINE__):(Class) class { \
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
#define SIStoreInStory(key, value) [(SIStory *) objc_getAssociatedObject(self, SI_INSTANCE_STORY_REF_KEY) storeObject:value withKey:key]

/**
 * The opposite of SISToreInStory(key, value) this macro retrieves a previously stored value.
 */
#define SIRetrieveFromStory(key) [(SIStory *) objc_getAssociatedObject(self, SI_INSTANCE_STORY_REF_KEY) retrieveObjectWithKey:key]

#pragma mark - Accessing the UI
/// @name UI interactions

/**
 Prints a tree view of the current window's UIView hirachy to the console. This is very useful for debugging and working out queries to location controls. 
 */
#define SIPrintCurrentWindowTree() [SIUIUtils logUITree]

/**
 Simple wrapper around dNodi's query facilities which returns a simple object from the display. This will trigger an error if the control is not found, so it is both a find and assert in one wrapper. 
 
 @param path a NSString containing the path to follow.
 @return a single UIView instance.
 */
#define SIFindView(path) [SIUIUtils findViewWithQuery:path]

/**
 Finds and returns an array of views. This does not assert anything about the views it is looking for.
 
 @param path a NSString containing the path to follow.
 @return a NSArray containing the found views.
 */
#define SIFindViews(path) [SIUIUtils findViewsWithQuery:path]

/**
 Finds the control specified by the path and taps it. How this tap in implemented is very dependent on the control as some controls are dificult to synthensize a tap for.
 
 @param path a NSString containing the path to the control.
 */
#define SITapControl(path) [SIUIUtils tapViewWithQuery:path]

/**
 Locates the button with the matching label and taps it.
 
 @param label the text label on the button to find.
 */
#define SITapButtonWithLabel(label) [SIUIUtils tapButtonWithLabel:label]

/**
 Locates the button with the matching label and taps it, then waits for the specified seconds before continuing.

 @param label the text label on the button to find.
 @param seconds how many seconds and/or part seconds to wait after tapping the button.
 */
#define SITapButtonWithLabelAndWait(label, seconds) [SIUIUtils tapButtonWithLabel:label andWait:seconds]

/**
 Locates the tab bar button with the matching label and taps it.
 
 @param label the text label of the tab bar button we want to tap.
 */
#define SITapTabBarButtonWithLabel(label) [SIUIUtils tapTabBarButtonWithLabel:label]

/**
 Locates a control based on a path and then performs a swipe on it.
 
 @param path a NSString containing the path to the control on the UI. This should yield only a single control.
 @param direction a SIUISwipeDirection value which indicates which direction to swipe in.
 @param distance how far to swipe in display points.
 */
#define SISwipeControlInDirectionDistance(path, direction, distance) [SIUIUtils swipeViewWithQuery:path inDirection:direction forDistance: distance]

/**
 But first some reuseable logic embedded in a macro.
 */

/// @name Basic Assertions

// These have been written because the others I was modelling off only worked within their respective frameworks. They take two forms. The base form is a simple macro. The *M form takes an addition set of parameters where you can specify a custom message. 

#pragma mark - Basic assertions

#define ASSERTION_EXCEPTION_NAME @"SIAssertionException"

#define SIThrowException(name, msgTemplate, ...) \
do { \
   NSString *_message = [NSString stringWithFormat:msgTemplate, ##__VA_ARGS__]; \
   NSString *_finalMessage = [NSString stringWithFormat:@"%s(%d) %@", __PRETTY_FUNCTION__, __LINE__, _message]; \
   DC_LOG(@"Throwing exception with message: %@", _finalMessage); \
   @throw [NSException exceptionWithName:name reason:_finalMessage userInfo:nil]; \
} while (NO)

/** 
 Generates a failure unconditionally. 
 */
#define SIFail() SIFailM(@"SIFail executed, throwing failure exception.")

/**
 Fail if the passed object variable is not a nil value.
 
 @param obj a variable of type id or NSObject* to test.
 */
#define SIAssertNotNil(obj) SIAssertNotNilM(obj, @"SIAssertNotNil(" #obj ") '" #obj "' should be a valid object.")

/**
 Fail if the passed object variable is a nil value.
 
 @param obj a variable of type id or NSObject* to test.
 */
#define SIAssertNil(obj) SIAssertNilM(obj, @"SIAssertNil(" #obj ") Expecting '" #obj "' to be nil.")

/**
 Fail if the passed BOOL variable is NO.
 
 @param exp an expression that is expected to resolve to a BOOL value. The expression can just be a simple BOOL variable name.
 */ 
#define SIAssertTrue(exp) SIAssertTrueM(exp, @"SIAssertTrue(" #exp ") Expecting '" #exp "' to be YES, but it was NO.")

/**
 Fail if the passed BOOL variable is YES.
 
 @param exp an expression that is expected to resolve to a BOOL value. The expression can just be a simple BOOL variable name.
 */ 
#define SIAssertFalse(exp) SIAssertFalseM(exp, @"SIAssertFalse(" #exp ") Expecting '" #exp "' to be NO, but it was YES.")

/*
 Fails if the two values are not equal. This works for all primitive numbers.
 
 @param x the first value to compare.
 @parma y the second value to compare.
 */
#define SIAssertEquals(x, y) SIAssertEqualsM(x, y, @"SIAssertEquals(" #x ", " #y ") failed: " #x @" != " #y)

/*
 Fails if the two objects are not equal. This basically calls the Object:isEquals: method on x giving y as a paramter.
 
 @param x the first object to compare.
 @parma y the second value to compare.
 */
#define SIAssertObjectEquals(x, y) \
   do { \
      id xValue = (x) == nil ? @"nil" : (x); \
      id yValue = (y) == nil ? @"nil" : (y); \
      SIAssertObjectEqualsM(x, y, [NSString stringWithFormat:@"SIAssertObjectEquals(%s, %s) failed: %@ != %@", #x, #y, xValue, yValue] ); \
   } while (NO)

#pragma mark - Assertions with custom messages

/// @name Assertions with custom messages

/*
 Same as above assertions but have extra parameters which are passed to NSString:stringWithFormat:
 */

#pragma mark - Main assertions
/// @name Main assertions

#define SIFailM(msgTemplate, ...) SIThrowException(ASSERTION_EXCEPTION_NAME, msgTemplate, ##__VA_ARGS__)

#define SIAssertNotNilM(obj, msgtemplate, ...) \
   if (obj == nil) { \
      SIThrowException(ASSERTION_EXCEPTION_NAME, msgtemplate, ##__VA_ARGS__); \
   }

#define SIAssertNilM(obj, msgTemplate, ...) \
   if (obj != nil) { \
      SIThrowException(ASSERTION_EXCEPTION_NAME, msgTemplate, ##__VA_ARGS__); \
   }

#define SIAssertTrueM(exp, msgTemplate, ...) \
   do { \
      BOOL _exp = exp; \
      if (!_exp) { \
         SIThrowException(ASSERTION_EXCEPTION_NAME, msgTemplate, ##__VA_ARGS__); \
      } \
   } while (NO)

#define SIAssertFalseM(exp, msgTemplate, ...) \
   do { \
      BOOL _exp = exp; \
      if (_exp) { \
         SIThrowException(ASSERTION_EXCEPTION_NAME, msgTemplate, ##__VA_ARGS__); \
      } \
   } while (NO)

#define SIAssertEqualsM(x, y, msgTemplate, ...) \
   SIAssertTrueM((x) == (y), msgTemplate, ##__VA_ARGS__);

#define SIAssertObjectEqualsM(x, y, msgTemplate, ...) \
   if ((x) != nil || (y) != nil) { \
      SIAssertTrueM([(id)(x) isEqual:(id)(y)], msgTemplate, ##__VA_ARGS__); \
   }

