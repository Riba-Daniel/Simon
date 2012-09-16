//
//  SIIncomingHTTPConnection.h
//  Simon
//
//  Created by Derek Clarkson on 13/07/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <CocoaHTTPServer/HTTPConnection.h>

/**
 Primary response class for handling incoming requests from CocoaHTTPServer classes. This then delegates out to SICoreHttpRequestProcessor implementations to handle individual requests.
 */
@interface SIHttpIncomingConnection : HTTPConnection

/// @name Tasks

/// Sets the list of SICoreHttpRequestProcessor classes which will be used when the SICoreHttpIncomingConnection instance is created by CocoaHTTPServer.
+(void) setProcessors:(NSArray *) processorArray;

@end
