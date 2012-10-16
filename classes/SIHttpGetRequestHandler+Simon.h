//
//  SIHttpGetRequestHandler+Simon.h
//  Simon
//
//  Created by Derek Clarkson on 26/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SIHttpGetRequestHandler.h>

/**
 Category on SIHttpGetRequestHandler containing internal methods. This is mainly so that the interface for SIHttpGetRequestHandler can remain simple.
 */
@interface SIHttpGetRequestHandler (Simon)

/// @name Tasks

/**
 Creates an object of the specified class and populates it with data from the passed JSON data stream.
 
 @param class the class that is to be instantiates.
 @param data a stream of data containing JSON which is to be used to populate the instance of the class.
 @param error a reference to an NSError variable which will be populated if an error occurs.
 @return an instance of class.
 */
-(id<SIJsonAware>) objectOfClass:(Class) class fromData:(NSData *) data error:(NSError **) error;

/**
 Factory method to create an object which conforms to the HTTPResponse protocol.
 
 The passed payload object is then serialised as the body of the response.
 
 @param payload the object to serialise as the body of the response.
 @return an NSObject which conforms to the HTTPResponse protocol.
 */
-(NSObject<HTTPResponse> *) httpResponseWithPayload:(id<SIJsonAware>) payload;

/**
 Generates an appropriate response object for the passed error.
 
 @param error the error encountered.
 @return a HTTPResponse protocol object.
 */
-(NSObject<HTTPResponse> *) httpResponseWithError:(NSError *) error;

@end
