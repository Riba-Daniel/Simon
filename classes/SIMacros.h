//
//  SIMacros.h
//  Simon
//
//  Created by Derek Clarkson on 7/1/11.
//  Copyright 2011. All rights reserved.
//
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIStepMapping.h>
#import <Simon/SIUIApplication.h>
#import <Simon/SIUIApplication+Text.h>
#import <Simon/SIUIApplication+Searches.h>
#import <Simon/SIUIApplication+Actions.h>
#import <Simon/SIConstants.h>
#import <Simon/SIStory.h>

/**
 These two are used to convert a sequence of chars to a string constant. We used this to convert a selector to a string constant within a macro when part of the macro name is the current line number macro __LINE__. Again we need that extra level of indirection to fix the translation of the parameter when stringification is involved.
 */
#define toNSString(chars) _toNSString(chars)
#define _toNSString(chars) @#chars

#pragma mark - Step mapping

/**
 This macro maps a regex to a selector in the current class. Simon expects that the order and type of any groups in the regex will
 match the order and types of arguments in the selector. So we recommend that this is used before the selector like this
 `
 SIMapStepToSelector(@"then use \"(.*)\" as the string value", thisIsMyMethod:);
 -(void) thisIsMyMethod:(NSString *) stringValue {
 ...
 }
 `
 */
#define mapStepToSelector(theRegex, aSelector) \
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
#define storeInStory(key, value) [(SIStory *) objc_getAssociatedObject(self, SI_INSTANCE_STORY_REF_KEY) storeObject:value withKey:key]

/**
 * The opposite of SISToreInStory(key, value) this macro retrieves a previously stored value.
 */
#define retrieveFromStory(key) [(SIStory *) objc_getAssociatedObject(self, SI_INSTANCE_STORY_REF_KEY) retrieveObjectWithKey:key]

#pragma mark - Accessing the UI
/// @name UI interactions

/**
 Prints a tree view of the current window's UIView hirachy to the console. This is very useful for debugging and working out queries to location controls. 
 */
#define printCurrentWindowTree() [[SIUIApplication application] logUITree]

/**
 Simple wrapper around dNodi's query facilities which returns a simple object from the display. This will trigger an error if the control is not found, so it is both a find and assert in one wrapper. 
 
 @param path a NSString containing the path to follow.
 @return a single UIView instance.
 */
#define withQuery(path) [[SIUIApplication application] viewWithQuery:path]

/**
 Finds and returns an array of views. This does not assert anything about the views it is looking for.
 
 @param query a NSString containing the path to follow.
 @return a NSArray containing the found views.
 */
#define viewsWithQuery(query) [[SIUIApplication application] viewsWithQuery:query]

/**
 Returns YES if the query returns one or more UIViews.
 
 @param query a NSString containing the path to follow.
 @return YES if one or more views are found, otherwise NO.
 */
#define isPresent(query) [[SIUIApplication application] isViewPresent:query]

/**
 Taps a UIView. The passed view can be either a UIView or a NSString containing a query which will locate it in the UI.
 
 @param view a NSString containing the path to the view or a UIView reference to the view.
 @return the UIView that was tapped.
 */
#define tap(view) \
	[[SIUIApplication application] tap:view]

/**
 Swipes a UIView in a given direction and distance. The passed view can be either a UIView or a NSString containing a query which will locate it in the UI.
 
 @param view a NSString containing the path to the view or a UIView reference to the view.
 @param direction a SIUISwipeDirection value which indicates which direction to swipe in.
 @param distance how far to swipe in display points.
 @return the UIView that was swiped.
 */
#define swipe(view, direction, distance) \
[[SIUIApplication application] swipe:(UIView *)view inDirection:direction forDistance: distance]

/**
 Pauses the current thread for the specified time. Note that this will only work on a background thread.
 
 @param seconds how many seconds to pause for.
 */
#define pauseFor(seconds) [[SIUIApplication application] pauseFor:seconds]

/**
 Checks for the existance of a query path on the UI periodically, up to a specified number of retries. Returns the control found (can be only one) or throws an
 exception if it is not found before the max number of retries is exected.
 
 @param query the query path that should locate the control.
 @param retryEvery the time interval between retries.
 @param maxRetryAttempts how many times to attempt to find the control before throwing an exception.
 */
#define waitForView(query, retryEvery, maxRetryAttempts) [[SIUIApplication application] waitForViewWithQuery:query retryInterval:retryEvery maxRetries:maxRetryAttempts]

/**
 Finds the view defined by path and waits until any animations which are active on it finish processing. This is tested periodically as defined by the checkEvery argument.
 Note that this takes into account any animations running on super views as well. So you can check a control which is on a view which is sliding on and it will be 
 regarded as being animated even though the control itself is not.

 @param query the query path that should locate the control.
 @param checkEvery the time interval to wait before checking for animations.
*/
#define waitForViewAnimationsToFinish(query, checkEvery) [[SIUIApplication application] waitForAnimationEndOnViewWithQuery:query retryInterval:checkEvery];

/**
 Brings up the keyboard and enters text into the field. If a query is passed this first finds the field before activating the keyboard.
 A SIUINotAnInputFieldException will be thrown if the passed view does not implement the UITextInput protocol.
 
 @param query the query path that should locate the control.
 @param text the text that you want entered. It is assumed that the text can be entered. I.e. that the field accepts it.
 */ 
#define enterText(view, text) \
[(view) isKindOfClass:[NSString class]] ? \
[[SIUIApplication application] enterText: text intoViewWithQuery:(NSString *)view] : \
[[SIUIApplication application] enterText: text intoView:(UIView *)view]
 
/**
 But first some reuseable logic embedded in a macro.
 */

/// @name Basic Assertions

// These have been written because the others I was modelling off only worked within their respective frameworks. They take two forms. The base form is a simple macro. The *M form takes an addition set of parameters where you can specify a custom message. 

#pragma mark - Basic assertions

#define ASSERTION_EXCEPTION_NAME @"SIAssertionException"

#define throwException(name, msgTemplate, ...) \
do { \
   NSString *message = [NSString stringWithFormat:msgTemplate, ## __VA_ARGS__]; \
   NSString *finalMessage = [NSString stringWithFormat:@"%s(%d) %@", __PRETTY_FUNCTION__, __LINE__, message]; \
   DC_LOG(@"Throwing exception with message: %@", finalMessage); \
   @throw [NSException exceptionWithName:name reason:finalMessage userInfo:nil]; \
} while (NO)

#pragma mark - Assertions

/// @name Main assertions

#define fail(msg) throwException(ASSERTION_EXCEPTION_NAME, msg)

#define assertNotNil(obj) \
   if (obj == nil) { \
      throwException(ASSERTION_EXCEPTION_NAME, @"assertNotNil(" #obj ") '" #obj "' should be a valid object."); \
   }

#define assertNil(obj) \
   if (obj != nil) { \
      throwException(ASSERTION_EXCEPTION_NAME, @"assertNil(" #obj ") Expecting '" #obj "' to be nil."); \
   }

#define assertTrue(exp) \
   do { \
      BOOL _exp = exp; \
      if (!_exp) { \
         throwException(ASSERTION_EXCEPTION_NAME, @"assertTrue(" #exp ") Expecting '" #exp "' to be YES, but it was NO."); \
      } \
   } while (NO)

#define assertFalse(exp) \
	do { \
		BOOL _exp = exp; \
		if (_exp) { \
			throwException(ASSERTION_EXCEPTION_NAME, @"assertFalse(" #exp ") Expecting '" #exp "' to be NO, but it was YES."); \
		} \
	} while (NO)

#define assertViewPresent(view) \
	do { \
		if (!isPresent(view)) { \
			throwException(ASSERTION_EXCEPTION_NAME, @"assertViewPresent(" #view ") Expected '" view "' to find a UIView."); \
		} \
	} while (NO)

#define assertViewNotPresent(view) \
	do { \
		if (isPresent(view)) { \
			throwException(ASSERTION_EXCEPTION_NAME, @"assertViewNotPresent(" #view ") Expected '" view "' to not find a UIView."); \
		} \
	} while (NO)

#define assertEquals(x, y) \
	if ((x) != (y)) { \
		throwException(ASSERTION_EXCEPTION_NAME, @"assertEquals(" #x ", " #y ") failed: " #x " != " #y); \
	}

// Compares if at least one is an object. Otherwise both are nil and that is ok too.
#define assertObjectEquals(x, y) \
   if ((x) != nil || (y) != nil) { \
		if (![(id)(x) isEqual:(id)(y)]) { \
			throwException(ASSERTION_EXCEPTION_NAME, @"assertObjectEquals(" #x ", " #y ") failed."); \
		} \
   } 

#define assertLabelTextEquals(label, expectedText) \
	do { \
		UILabel *theLabel = nil; \
		if ([label isKindOfClass:[NSString class]]) { \
			theLabel = (UILabel *) withQuery((NSString *) label); \
		} else { \
			theLabel = (UILabel *) label; \
		} \
		NSString *labelText = theLabel.text; \
		if (![labelText isEqual:expectedText]) { \
			throwException(ASSERTION_EXCEPTION_NAME, @"assertLabelTextEquals(" #label ", " #expectedText ") failed. Found label text: '%@' instead.", labelText); \
		} \
	} while (NO)

