//
//  SIConstants.h
//  Simon
//
//  Created by Derek Clarkson on 6/10/11.
//  Copyright (c) 2011. All rights reserved.
//

#import <Simon/SIJsonAware.h>

#define STORY_EXTENSION @"stories"

// Http server config.
#define HTTP_SIMON_HOST @"localhost"
#define HTTP_PIEMAN_HOST @"localhost"
#define HTTP_SIMON_PORT 44123
#define HTTP_PIEMAN_PORT 44321
#define HTTP_REQUEST_TIMEOUT 5.0
#define HTTP_MAX_RETRIES 5
#define HTTP_RETRY_INTERVAL 2.0f

/**
 * The prefix used to start the method names for the step definition.
 */
#define SI_STEP_METHOD_PREFIX __stepMap

// Thread names.
#define PIEMAN_QUEUE_NAME @"au.com.derekclarkson.pieman"
#define SIMON_QUEUE_NAME "au.com.derekclarkson.simon.comms"

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

// Common command line args.
#define ARG_SIMON_PORT @"-simon-port"
#define ARG_PIEMAN_PORT @"-pieman-port"

// Program arguments.
#define ARG_NO_LOAD @"-no-load"
#define ARG_SHOW_UI @"-ui"
#define ARG_AUTORUN @"-autorun"
#define ARG_LOG_ACTIONS @"-log-actions"
#define ARG_REPORT @"-report"

// Http paths
#define HTTP_PATH_SIMON_READY @"/simon/ready"
#define HTTP_PATH_RUN_ALL @"/run/all"
#define HTTP_PATH_RUN_FINISHED @"/run/finished"
#define HTTP_PATH_STORY_FINISHED @"/story/finished"
#define HTTP_PATH_HEARTBEAT @"/heartbeat"
#define HTTP_PATH_EXIT @"/exit"

// Block definitions.

typedef void (^SimpleBlock)();

// Blocks for HTTP requests and responses.
typedef void (^RequestSentBlock)(id<SIJsonAware> bodyObj);
typedef void (^RequestSentErrorBlock)(id<SIJsonAware> bodyObj, NSError *error);

typedef id<SIJsonAware> (^RequestReceivedBlock)(id<SIJsonAware> bodyObj);

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
	SIKeywordStory = 1,
	SIKeywordAs,
	SIKeywordGiven,
	SIKeywordWhen,
	SIKeywordThen,
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
	SIStoryStatusNotRun,
	SIStoryStatusCount
} SIStoryStatus;

/**
 The current status of a step.
 */
typedef enum {
	SIStepStatusNotMapped,
	SIStepStatusNotRun,
	SIStepStatusSuccess,
	SIStepStatusFailed,
} SIStepStatus;

/**
 Defines the methods that can be accepted by the http server.
 */
typedef enum {
	SIHttpMethodUnknown,
	SIHttpMethodGet,
	SIHttpMethodPost
} SIHttpMethod;

/**
 Defines status codes that can be sent back in Http response bodies.
 */
typedef enum {
	SIHttpStatusOk,
	SIHttpStatusError
} SIHttpStatus;

