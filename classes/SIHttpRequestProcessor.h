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
@interface SIHttpRequestProcessor: NSObject

-(BOOL) canProcessPath:(NSString *) path withMethod:(SIHttpMethod) method;

-(NSObject<HTTPResponse> *) processPath:(NSString *) path withMethod:(SIHttpMethod) method andBody:(NSString *) body;

-(BOOL) expectingHttpBody;

@end

