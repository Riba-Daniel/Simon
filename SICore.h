//
//  SICore.h
//  Simon
//
//  Created by Derek Clarkson on 9/09/12.
//  Copyright (c) 2012. All rights reserved.
//

// Definitions common to both Simon and the Pieman.

#import <Simon/SIJsonAware.h>

// Http server config.
#define HTTP_SIMON_HOST @"localhost"
#define HTTP_PIEMAN_HOST @"localhost"
#define HTTP_SIMON_PORT 44123
#define HTTP_PIEMAN_PORT 44321
#define HTTP_REQUEST_TIMEOUT 5.0
#define HTTP_MAX_RETRIES 5
#define HTTP_RETRY_INTERVAL 2.0f

// Common command line args.
#define ARG_SIMON_PORT @"-simon-port"
#define ARG_PIEMAN_PORT @"-pieman-port"

// Http paths
#define HTTP_PATH_SIMON_READY @"/simon/ready"
#define HTTP_PATH_RUN_ALL @"/run/all"
#define HTTP_PATH_RUN_FINISHED @"/run/finished"
#define HTTP_PATH_STORY_FINISHED @"/story/finished"
#define HTTP_PATH_HEARTBEAT @"/heartbeat"
#define HTTP_PATH_EXIT @"/exit"

// Thread names.
#define PIEMAN_QUEUE_NAME @"au.com.derekclarkson.pieman"
#define SIMON_QUEUE_NAME "au.com.derekclarkson.simon.comms"

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
