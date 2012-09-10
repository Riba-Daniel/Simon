//
//  SIConstants.h
//  Simon
//
//  Created by Derek Clarkson on 6/10/11.
//  Copyright (c) 2011. All rights reserved.
//

#define STORY_EXTENSION @"stories"

/**
 * The prefix used to start the method names for the step definition.
 */
#define SI_STEP_METHOD_PREFIX __stepMap

/// Error domain for NSError's that Simon generates.
#define SIMON_ERROR_DOMAIN @"SIError"

// keys for references attached to implementation classes.
#define SI_INSTANCE_STORY_REF_KEY @"__story" 
#define SI_INSTANCE_STEP_MAPPING_REF_KEY @"__stepMapping" 

// Notification ids.
#define SI_STORY_STARTING_EXECUTION_NOTIFICATION @"Story starting execution"
#define SI_STORY_EXECUTED_NOTIFICATION @"Story has executed"
#define SI_RUN_STARTING_NOTIFICATION @"Simon run starting"
#define SI_RUN_FINISHED_NOTIFICATION @"Simon run finished"
#define SI_SHUTDOWN_NOTIFICATION @"Simon shutdown"
#define SI_HIDE_WINDOW_RUN_STORIES_NOTIFICATION @"Simon hide window and run stories"
#define SI_RUN_STORIES_NOTIFICATION @"Simon run stories"

// Keys for notification dictionaries.
#define SI_NOTIFICATION_KEY_SOURCE @"Source"
#define SI_NOTIFICATION_KEY_STORY @"Story"
#define SI_NOTIFICATION_KEY_STATUS @"Status"
#define SI_NOTIFICATION_KEY_MESSAGE @"Message"

// Program arguments.
#define ARG_NO_LOAD @"-no-load"
#define ARG_SHOW_UI @"-ui"
#define ARG_AUTORUN @"-autorun"
#define ARG_LOG_ACTIONS @"-log-actions"

#define SEND_READY_MAX_RETRIES 5
#define SEND_READY_RETRY_INTERVAL 2.0

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

