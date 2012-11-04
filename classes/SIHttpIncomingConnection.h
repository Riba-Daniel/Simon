//
//  SIIncomingHTTPConnection.h
//  Simon
//
//  Created by Derek Clarkson on 13/07/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <CocoaHTTPServer/HTTPConnection.h>

/**
 Primary response class for handling incoming requests from CocoaHTTPServer classes. This then delegates out to SIHttpRequestProcessor implementations to handle individual requests.
 */
@interface SIHttpIncomingConnection : HTTPConnection

/// @name Tasks

/** 
 Sets the list of SIHttpRequestProcessor classes which will be used when the SIHttpIncomingConnection instance is created by CocoaHTTPServer.
 
 @param processorArray a NSArray containing instances of SIHttpGetRequestHandler and SIHttpPostRequestHandler which will respond to various incoming requests.
*/
+(void) setProcessors:(NSArray *) processorArray;

@end
