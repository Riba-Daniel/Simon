//
//  SIHttpRequest.h
//  Simon
//
//  Created by Derek Clarkson on 24/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Classes which implment this protocol will be tested to see if they can respond to a specific HTTP request.
 */
@protocol SIHttpRequest <NSObject>

-(BOOL) canProcessPath:(NSString *) path withMethod:(HttpMethod) method;

-(BOOL) processPath:(NSString *) path withMethod:(HttpMethod) method;

@end
