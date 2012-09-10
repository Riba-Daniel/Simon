//
//  SIHttpResponseBody.h
//  Simon
//
//  Created by Derek Clarkson on 29/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Simon/SIJsonAware.h>
#import <Simon/SICore.h>

#define RESPONSE_JSON_KEY_STATUS @"status"

/**
 Simple object that is used to serial response bodies back to the Pieman.
 */
@interface SICoreHttpSimpleResponseBody : NSObject<SIJsonAware>

@property (nonatomic) SIHttpStatus status;

@end
