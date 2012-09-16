//
//  SIHttpPostRequestHandler.h
//  Simon
//
//  Created by Derek Clarkson on 16/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SIHttpGetRequestHandler.h>

/**
 Extends the GET request processing to handle POST requests.
 */
@interface SIHttpPostRequestHandler : SIHttpGetRequestHandler

/// @name Initialisers

/**
 Default initialiser.
 
 @param path the path it will respond to.
 @param requestBodyClass the Class that will be mapped from the incoming requet body. Must conform to SIJsonAware protocol. If there is no expected body then pass a NULL.
 @param requestReceivedBlock a block to be executed once the body has been mapped into an instance of the body class.
 
 @return an instance of this class.
 */
-(id) initWithPath:(NSString *) path
  requestBodyClass:(Class) requestBodyClass
			  process:(RequestReceivedBlock) requestReceivedBlock;

@end
