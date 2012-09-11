//
//  SICore.h
//  Simon
//
//  Created by Derek Clarkson on 9/09/12.
//  Copyright (c) 2012. All rights reserved.
//

// Definitions common to both Simon and the Pieman.

// Http server config.
#define HTTP_SIMON_HOST @"localhost"
#define HTTP_PIEMAN_HOST @"localhost"
#define HTTP_SIMON_PORT 44123
#define HTTP_PIEMAN_PORT 44321
#define HTTP_REQUEST_TIMEOUT 5.0

// Common command line args.
#define ARG_SIMON_PORT @"-simon-port"
#define ARG_PIEMAN_PORT @"-pieman-port"

// Http paths
#define HTTP_PATH_SIMON_READY @"/simon/ready"
#define HTTP_PATH_RUN_ALL @"/run/all"
#define HTTP_PATH_HEARTBEAT @"/heartbeat"
#define HTTP_PATH_EXIT @"/exit"

// Thread names.
#define PIEMAN_QUEUE_NAME @"au.com.derekclarkson.pieman"
#define SIMON_QUEUE_NAME "au.com.derekclarkson.simon.comms"

// Block definitions.
typedef void (^SimpleBlock)();
typedef void (^ResponseBlock)(id obj);
typedef void (^ResponseErrorBlock)(id obj, NSString *errorMsg);

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
