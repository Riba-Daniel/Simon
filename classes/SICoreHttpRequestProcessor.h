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
@interface SICoreHttpRequestProcessor: NSObject

/// @name Tasks

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
 @param method the GET, POST etc http method.
 @param body the body part of the request if there is any.
 */
-(NSObject<HTTPResponse> *) processPath:(NSString *) path withMethod:(SIHttpMethod) method andBody:(NSString *) body;

/**
 Returns YES if the processor is expecting a request body.
 
 @return YES if a body is expected.
 */
-(BOOL) expectingHttpBody;

@end

