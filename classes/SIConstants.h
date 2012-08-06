//
//  SIConstants.h
//  Simon
//
//  Created by Derek Clarkson on 6/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#define STORY_EXTENSION @"stories"

/**
 * The prefix used to start the method names for the step definition.
 */
#define SI_STEP_METHOD_PREFIX __stepMap

#define IPAD_HEADER_INDENT 55
#define IPHONE_HEADER_INDENT 20

/// Error domain for NSError's that Simon generates.
#define SIMON_ERROR_DOMAIN @"SIError"

// keys for references attached to implementation classes.
#define SI_INSTANCE_STORY_REF_KEY @"__story" 
#define SI_INSTANCE_STEP_MAPPING_REF_KEY @"__stepMapping" 

// Notification ids.
#define SI_STORY_EXECUTED_NOTIFICATION @"Story has executed"
#define SI_RUN_FINISHED_NOTIFICATION @"Simon run finished"
#define SI_SHUTDOWN_NOTIFICATION @"Simon shutdown"
#define SI_RUN_STORIES_NOTIFICATION @"Simon run stories"
#define SI_WINDOW_REMOVED_NOTIFICATION @"Simon window removed"

// Keys for notification dictionaries.
#define SI_NOTIFICATION_KEY_SOURCE @"Source"
#define SI_NOTIFICATION_KEY_STORY @"Story"

// Program arguments.
#define ARG_NO_LOAD @"--no-load"
#define ARG_SHOW_UI @"--ui"
#define ARG_NO_AUTORUN @"--no-autorun"
#define ARG_LOG_ACTIONS @"--log-actions"

// Simon's background thread name.
#define SI_QUEUE_NAME "au.com.derekclarkson.simon"

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



