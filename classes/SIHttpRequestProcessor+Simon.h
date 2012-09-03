//
//  SIHttpRequestProcessor+Simon.h
//  Simon
//
//  Created by Derek Clarkson on 29/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Simon/SIHttpRequestProcessor.h>

/**
 Category which adds functionality to SIHttpRequestProcessors that we do not want exposed normally.
 */
@interface SIHttpRequestProcessor (Simon)

/**
 Creates a Httpresponse with the passed object converted to JSON and set as the response body.
 
 @param body the object that implements the SIJsonAware protocol.
 @return a object implementing the HTTPResponse protocol which has the JSON payload set.
 */
-(NSObject<HTTPResponse> *) httpResponseWithBody:(id<SIJsonAware>) body;

@end
