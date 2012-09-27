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

#define PAYLOAD_KEY_STATUS @"status"
#define PAYLOAD_KEY_MESSAGE @"message"

/**
 Base obejct for any content of a request or response.
 */
@interface SIHttpPayload : NSObject<SIJsonAware>

/// @name Properties

/// The status of the request.
@property (nonatomic) SIHttpStatus status;

/// Any associated message.
@property (nonatomic, retain) NSString *message;


/// @name Default initialiser.

/**
 Default initialiser.
 
 @param status the status
 @param message an associated message. Can be nil.
 @return an instance of this class.
 */
-(id<SIJsonAware>) initWithStatus:(SIHttpStatus) status
								  message:(NSString *) message;

/**
 Factory methof which takes a status and mesage parameter.
 
 @param status the status
 @param message an associated message. Can be nil.
 @return an autorelease instance of this class.
 */
+(id<SIJsonAware>) httpPayloadWithStatus:(SIHttpStatus) status
											message:(NSString *) message;

@end
