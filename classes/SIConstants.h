//
//  SIConstants.h
//  Simon
//
//  Created by Derek Clarkson on 6/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

/**
 The name of the field dynamically added to classes which contain step implementations. A reference to the parent story is set on this key effectively giving the class access to the story without the author having to write any code.
 */
extern const NSString * SI_INSTANCE_STORY_REF_KEY;

/**
The name of the field dynamically added to classes which contain step implementations. A reference to the parent story is set on this key effectively giving the class access to the story without the author having to write any code.
*/
extern const NSString * SI_INSTANCE_STEP_MAPPING_REF_KEY;

/**
 Key of the notification sent when we want to shutdown Simon.
 */
extern NSString * SI_RUN_FINISHED_NOTIFICATION;

/**
 Key of the notification sent when we want to shutdown Simon.
 */
extern NSString * SI_SHUTDOWN_NOTIFICATION;

/**
 Key of the notification sent when we want to re-run a single story.
 */
extern NSString * SI_RERUN_SINGLE_NOTIFICATION;

/**
 Key of the notification sent when we want to re-run a group of stories.
 */
extern NSString * SI_RERUN_GROUP_NOTIFICATION;

/**
 Id of our main background thread. Note this is a const char "*", i.e. no '@' to declare a NSString.
 */
extern const char * SI_QUEUE_NAME;

/**
 This gives the types of keywords read by SIStoryFileReader. SIKeywordNone is used only when the first story is beng read as it designates
 the start of the file.
 */
typedef enum {
	SIKeywordUnknown = 999,
	SIKeywordStartOfFile = 0,
	SIKeywordNone,
	SIKeywordStory,
	SIKeywordGiven,
	SIKeywordThen,
	SIKeywordAs,
	SIKeywordAnd
} SIKeyword;

/// Error domain for NSError's that Simon generates.
#define SIMON_ERROR_DOMAIN @"SIError"

/**
 Individual error codes.
 */
typedef enum {
	SIErrorInvalidStorySyntax = 1, /// Generated when there is an issue with the syntax used in a story file.
	SIErrorInvalidKeyword, 
	SIErrorInvalidRegularExpression,
	SIErrorUnknownSelector,
	SIErrorCannotConvertArgumentToType,
	SIErrorRegularExpressionWillNotMatchSelector,
	SIErrorNoStoriesFound,
	SIErrorStoryFailures,
	SIErrorExceptionCaught,
	SIErrorUnknownProperty
} SIError;

/**
 Gives the final status of a story after the run.
 */
typedef enum {
	SIStoryStatusSuccess = 0,
	SIStoryStatusIgnored,
	SIStoryStatusError,
	SIStoryStatusNotMapped,
	SIStoryStatusNotRun
} SIStoryStatus;





