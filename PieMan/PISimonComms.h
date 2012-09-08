//
//  PISimon.h
//  Simon
//
//  Created by Derek Clarkson on 8/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PISimonCommsDelegate.h"
#import "PIConstants.h"

/**
 This class handles communications between the Pieman and Simon.
 */
@interface PISimonComms : NSObject

/// @name Delegate

@property (nonatomic, assign) id<PISimonCommsDelegate> delegate;

/// @name Tasks

/**
 Generic send method for transmitting a request to Simon and processing the response.
 
 @param path the REST path to send. This will be added to Simon's server and port address.
 @param responseBodyClass the class that the JSON response class is expected to be loaded into.
 @param responseBlock a block which will be executed after the response has been converted to the responseBodyClass instance.
 @param responseErrorBlock a block which is called if there is an error.
 */
-(void) sendRESTRequest:(NSString *) path
		responseBodyClass:(Class) responseBodyClass
		  onResponseBlock:(ResponseBlock) responseBlock
			  onErrorBlock:(ResponseErrorBlock) responseErrorBlock;

@end
