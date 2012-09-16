//
//  SIHttpRequest.h
//  Simon
//
//  Created by Derek Clarkson on 24/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Simon/SICore.h>
#import <CocoaHTTPServer/HTTPResponse.h>
#import <Simon/SIJsonAware.h>

/**
 Classes which extend this abstract class will be tested to see if they can respond to a specific HTTP request.
 */
@interface SIHttpGetRequestHandler: NSObject

/// @name Properties

/// The path that this handler responds to.
@property (nonatomic, retain) NSString *path;

/// @name Initialisers

/**
 Default initialiser.
 
 @param path the path it will respond to.
 @param requestReceivedBlock a block to be executed once the body has been mapped into an instance of the body class.
 
 @return an instance of this class.
 */
-(id) initWithPath:(NSString *) path process:(RequestReceivedBlock) requestReceivedBlock;

/// @name Tasks

/**
 Indicates of the processor is expecting a message body.

 @return YES if the processor has been passed a body class. Therefore is expecting JSON content to be passed.
 */
-(BOOL) expectingHttpBody;

/**
 Asks the request processor if it can respond to a specific request.
 
 @param path the path element of the url.
 @param method the GET, POST etc http method.
 @return YES if the processor can handle the method.
 */
-(BOOL) canProcessPath:(NSString *) path withMethod:(SIHttpMethod) method;

/**
 Processes the request.
 
 @param path the path element of the url.
 @param body the body part of the request if there is any.
 */
-(NSObject<HTTPResponse> *) processPath:(NSString *) path andBody:(NSData *) body;

/**
 Override to generate content from POST requests.
 
 @param body the NSData object containing the content of a POST request.
 @return the body parameter converted to an object which conforms to the SIJsonAware protocol.
 */
-(id<SIJsonAware>) bodyObjectFromBody:(NSData *) body;

/**
 Generates an appropriate response object for the passed error.
 
 @param error the error encountered.
 @return a HTTPResponse protocol object.
 */
-(NSObject<HTTPResponse> *) responseForError:(NSError *) error;

@end

