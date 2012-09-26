//
//  SICoreHttpConnection.h
//  Simon
//
//  Created by Derek Clarkson on 9/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SICore.h>

/**
 This class manages an outgoing connection.
 */
@interface SIHttpConnection : NSObject

/**
 Main intialiser.
 
 @param url the url to send stuff too. Should be the full scheme://host:port combination.
 @param sendQ the GCD queue that will be used for sending the request.
 @param replyQ the GCD queue which will be used for executing the response blocks.
 @return an instance of this class.
 */
-(id) initWithHostUrl:(NSString *) url
			sendGCDQueue:(dispatch_queue_t) sendQ
	  responseGCDQueue:(dispatch_queue_t) replyQ;

/**
 Generic get request method for transmitting a request to Simon and processing the response. The request is executed on the sendQ GCD queue and the response is processed and returned on the replyQ GCD queue. This allows for smoother multithreading.
 
 @param path the REST path to send. This will be added to the server and port address.
 @param responseBodyClass the class that the JSON response class is expected to be loaded into. nil if there is no response data expected.
 @param successBlock a block which will be executed after the response has been converted to the responseBodyClass instance. Pass NULL if there is no block.
 @param errorBlock a block which is called if there is an error. Pass NULL if there is no block.
 */
-(void) sendRESTGetRequest:(NSString *) path
			responseBodyClass:(Class) responseBodyClass
				  successBlock:(RequestSentBlock) successBlock
					 errorBlock:(RequestSentErrorBlock) errorBlock;

/**
 Generic send method for transmitting a request to Simon and processing the response. The request is executed on the sendQ GCD queue and the response is processed and returned on the replyQ GCD queue. This allows for smoother multithreading.
 
 @param path the REST path to send. This will be added to the server and port address.
 @param method the SIHttpMethod to set on the request.
 @param requestBody an instance that conforms to the SIJsonAware protocol. This will be serialsed as the request body in a POST operation.
 @param responseBodyClass the class that the JSON response class is expected to be loaded into. nil if there is no response data expected.
 @param successBlock a block which will be executed after the response has been converted to the responseBodyClass instance. Pass NULL if there is no block.
 @param errorBlock a block which is called if there is an error. Pass NULL if there is no block.
 */
-(void) sendRESTRequest:(NSString *) path
					  method:(SIHttpMethod) method
				requestBody:(id<SIJsonAware>) requestBody
		responseBodyClass:(Class) responseBodyClass
			  successBlock:(RequestSentBlock) successBlock
				 errorBlock:(RequestSentErrorBlock) errorBlock;

@end
