//
//  SIActionFactory.h
//  Simon
//
//  Created by Derek Clarkson on 8/08/11.
//  Copyright 2011. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SIUIViewHandler.h"

/**
 This factory creates instances of UI hanlders that can respond to dNodi requests for data and perform actions such as taps and swipes on controls.
 This faction also provides the extension point for handling. ou can extend it and override it's methods to intercept and return your custom SIUIAction classes. Just don't
 forget to call the super version as well.
 
 The easiest way to do this is to create a Category on this factory which overrides the createFactory method and returns your extension of this class. 
 */
@interface SIUIHandlerFactory : NSObject {
	@private
	NSMutableDictionary *handlerCache;
}

/// @name Factory

/**
 Sets a new factory for creating actions. Normally you would not use this unless you want to extend the SIUIActionFactory class to implement your own factory methods.
 
 @param handlerFactory the new factory to set. 
 */
+(void) setHandlerFactory:(SIUIHandlerFactory *) handlerFactory;

/**
 Returns the current factory instance. If it is nil, then an instance of SIUIHandlerFactory is created first.
 */
+(SIUIHandlerFactory *) handlerFactory;


/// @name Tasks

/**
 Factory method for creating a handler object for a specific view class.
 */
-(SIUIViewHandler *) createHandlerForView:(UIView<DNNode> *) view;

@end
