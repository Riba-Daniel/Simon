//
//  SIMacros.h
//  Simon
//
//  Created by Derek Clarkson on 7/1/11.
//  Copyright 2011. All rights reserved.
//
#import <dUsefulStuff/DCCommon.h>

#pragma Internal functions

// Place Simons logging under a different flag so that we can seperate it from other logging.
#ifdef SI_DEBUG
#define SI_LOG(s, ...) DC_LOG(s, __VA_ARGS__)
#else
#define SI_LOG(s, ...) 
#endif

#pragma mark - Runners

/**
 This macro must be placed in your startup code. It loads Simon into the background and automatically runs the stories once the application is active and ready.
 If you want a particular story file to be run, just enter it's name as a parameter.
 */
#ifdef SI_DEBUG

#define SIRun() \
SIAppBackpack *backpack = [[[SIAppBackpack alloc] init] autorelease]; \
SI_LOG(@"Started backpack %@", [backpack description]);

#define SIRunFile(storyFile) \
SIAppBackpack *backpack = [[[SIAppBackpack alloc] initWithStoryFile:storyFile] autorelease]; \
SI_LOG(@"Started backpack %@", [backpack description]);

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
+(SIStepMapping *) DC_CONCATINATE(SI_STEP_METHOD_PREFIX, __LINE__):(Class) class { \
SI_LOG(@"Creating mapping \"%@\" -> %@::%@", theRegex, NSStringFromClass(class), toNSString(aSelector)); \
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

// These have been written because the others I was modelling off only worked within their respective frameworks. They take two forms. The base form is a simple macro. The *M form takes an addition set of parameters where you can specify a custom message. 

/// @name Assertions

/**
 But first some reuseable logic embedded in a macro.
 */
#define SIThrowException(defaultMsg, description, ...) \
SI_LOG(@"Throwing exception"); \
NSString *_message = defaultMsg; \
if (description) { \
_message = [NSString stringWithFormat:description, ##__VA_ARGS__]; \
} \
NSString *_finalMessage = [NSString stringWithFormat:@"%s(%d) %@", __PRETTY_FUNCTION__, __LINE__, _message]; \
SI_LOG(@"Setting exception with message: %@", _finalMessage); \
@throw [NSException exceptionWithName:@"SIAssertionException" reason:_finalMessage userInfo:nil]; \
return

/** 
 Generates a failure unconditionally. 
 
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present. A nil tells Simon to use a default message.
 @param ... A variable number of arguments to the format string. Can be absent.
 */
#define SIFail() SIFailM(nil);
#define SIFailM(description, ...) \
SIThrowException(@"SIFail executed, throwing failure exception.", description, ##__VA_ARGS__);

/**
 Fail if the passed object variable is not a nil value.
 
 @param obj a variable of type id or NSObject* to test.
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present. A nil tells Simon to use a default message.
 @param ... A variable number of arguments to the format string. Can be absent.
 */
#define SIAssertNotNil(obj) _SIAssertNotNil(#obj, obj, nil)
#define SIAssertNotNilM(obj, description, ...) _SIAssertNotNil(#obj, obj, description, ##__VA_ARGS__)
#define _SIAssertNotNil(expr, obj, description, ...) \
do { \
if (obj == nil) { \
SIThrowException(@"Expecting '" expr "' to be a valid pointer to something.", description, ##__VA_ARGS__); \
} \
} while (NO)

/**
 Fail if the passed object variable is a nil value.
 
 @param obj a variable of type id or NSObject* to test.
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present. A nil tells Simon to use a default message.
 @param ... A variable number of arguments to the format string. Can be absent.
 */
#define SIAssertNil(obj) _SIAssertNil(#obj, obj, nil)
#define SIAssertNilM(obj, description, ...) _SIAssertNil(#obj, obj, description, ##__VA_ARGS__)
#define _SIAssertNil(expr, obj, description, ...) \
do { \
if (obj != nil) { \
SIThrowException(@"Expecting '" expr "' to be nil.", description, ##__VA_ARGS__); \
} \
} while (NO)

/**
 Fail if the passed BOOL variable is NO.
 
 @param exp an expression that is expected to resolve to a BOOL value. The expression can just be a simple BOOL variable name.
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present. A nil tells Simon to use a default message.
 @param ... A variable number of arguments to the format string. Can be absent.
 */ 
#define SIAssertTrue(exp) _SIAssertTrue(#exp, exp, nil)
#define SIAssertTrueM(exp, description, ...) _SIAssertTrue(#exp, exp, description, ##__VA_ARGS__)
#define _SIAssertTrue(expr, exp, description, ...) \
do { \
BOOL _exp = exp; \
if (!_exp) { \
SIThrowException(@"Expecting '" expr "' to be YES, but it was NO.", description, ##__VA_ARGS__); \
} \
} while (NO)

/**
 Fail if the passed BOOL variable is YES.
 
 @param exp an expression that is expected to resolve to a BOOL value. The expression can just be a simple BOOL variable name.
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present. A nil tells Simon to use a default message.
 @param ... A variable number of arguments to the format string. Can be absent.
 */ 
#define SIAssertFalse(exp) _SIAssertFalse(#exp, exp, nil)
#define SIAssertFalseM(exp, description, ...) _SIAssertFalse(#exp, exp, description, ##__VA_ARGS__)
#define _SIAssertFalse(expr, exp, description, ...) \
do { \
BOOL _exp = exp; \
if (_exp) { \
SIThrowException(@"Expecting '" expr "' to be NO, but it was YES.", description, ##__VA_ARGS__); \
} \
} while (NO)

/*
 const char *tX = @encode(__typeof__(x)); \
 #DEFINE typeX @encode(__typeof__(x)) \
 const char *tY = @encode(__typeof__(y)); \
 DC_LOG(@"type of x: %s", tX); \
 DC_LOG(@"type of y: %s", tY); \
 \
 BOOL isPrimitiveNumberX = strchr("islLqLfd", tX[0]) != NULL; \
 DC_LOG(@"type of x is a number %@", DC_PRETTY_BOOL(isPrimitiveNumberX)); \
 BOOL isPrimitiveNumberY = strchr("islLqLfd", tY[0]) != NULL; \
 DC_LOG(@"type of x is a number %@", DC_PRETTY_BOOL(isPrimitiveNumberY)); \
 \
 if isPrimitiveNumberX && isPrimitiveNumberY \
 DC_LOG(@"Both sides are primitive numbers"); \
 SIAssertTrueM(x == y, notEqualsMsg); \
 } \
 \
 if (strcmp(tX, tY) != 0) { \
 DC_LOG(@"Types types don't match"); \
 SIFailM(@"SIAssertEquals failed: " #x @" and " #y " are different types"); \
 } \
 \
 */
#define SIAssertEquals(x,y) \
do { \
NSString *notEqualsMsg = (@"SIAssertEquals failed: " #x @" != " #y); \
SIAssertTrueM((x) == (y), notEqualsMsg); \
} while(NO);

#define SIAssertObjectEquals(x,y) \
do { \
if ((x) == nil && (y) == nil) { \
break; \
} \
NSString *notEqualsMsg = (@"SIAssertEquals failed: " #x @" != " #y); \
SIAssertTrueM([(id)(x) isEqual:(id)(y)], notEqualsMsg); \
} while(NO);





