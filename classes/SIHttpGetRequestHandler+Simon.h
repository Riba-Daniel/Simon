//
//  SIHttpGetRequestHandler+Simon.h
//  Simon
//
//  Created by Derek Clarkson on 26/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SIHttpGetRequestHandler.h>

@interface SIHttpGetRequestHandler (Simon)

-(id<SIJsonAware>) objectOfClass:(Class) class fromData:(NSData *) data error:(NSError **) error;

-(NSObject<HTTPResponse> *) httpResponseWithPayload:(id<SIJsonAware>) payload;

/**
 Generates an appropriate response object for the passed error.
 
 @param error the error encountered.
 @return a HTTPResponse protocol object.
 */
-(NSObject<HTTPResponse> *) httpResponseWithError:(NSError *) error;

@end
