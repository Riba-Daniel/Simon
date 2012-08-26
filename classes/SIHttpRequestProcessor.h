//
//  SIHttpRequest.h
//  Simon
//
//  Created by Derek Clarkson on 24/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SIConstants.h>
#import <CocoaHTTPServer/HTTPResponse.h>

/**
 Classes which implment this protocol will be tested to see if they can respond to a specific HTTP request.
 */
@protocol SIHttpRequestProcessor <NSObject>

-(BOOL) canProcessPath:(NSString *) path withMethod:(SIHttpMethod) method;

-(NSObject<HTTPResponse> *) processPath:(NSString *) path withMethod:(SIHttpMethod) method andBody:(NSString *) body;

-(BOOL) expectingHttpBody;

@end
