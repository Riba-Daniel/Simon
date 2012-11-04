//
//  SIHttpRequest.h
//  Simon
//
//  Created by Derek Clarkson on 24/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Simon/SIConstants.h>
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
 Called to run the processing block and handles any object it returns. If the return value is nil, this will geneate a simple payload with a success status.
 
 @param payload the request body after converting to an object.
 @return any response object from the processing block or an instance of SIHttpPayload with a status of 0 (SIHttpSuccess).
 */
-(id<SIJsonAware>) runProcessWithRequestPayload:(id<SIJsonAware>) payload;

@end

