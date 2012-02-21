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
@interface SIUIViewHandlerFactory : NSObject {
	@private
	NSMutableDictionary *handlerCache;
}

/// @name Factory

/**
 Sets a new factory for creating actions. Normally you would not use this unless you want to extend the SIUIActionFactory class to implement your own factory methods.
 
 @param handlerFactory the new factory to set. 
 */
+(void) setHandlerFactory:(SIUIViewHandlerFactory *) handlerFactory;

/**
 Returns the current factory instance. If it is nil, then an instance of SIUIHandlerFactory is created first.
 */
+(SIUIViewHandlerFactory *) handlerFactory;

/**
 Shuts down the factory and releases memory.
 */
+(void) shutDown;


/// @name Tasks

/**
 Call this method to obtain a handler for a view. This method manages the creation and caching of handlers and calls createHandlerForView: to obtain new handlers as necessary.
 
 @param view the view we need the handler for.
 */
-(SIUIViewHandler *) handlerForView:(UIView<DNNode> *) view;

/**
 This does the work of creating a handler. If you want to create a custom implementation of this class to create your own handlers. Override this method to do the creation. Like all create methods this should return an autoreleased object. Note that this will only be called once per view class as handlers are cached and reused.
 
 @see initHandler:withView:
 @param view the view we want to obtain a handler for.
 @result the appropriate handler.
 */
-(SIUIViewHandler *) createHandlerForView:(UIView<DNNode> *) view;

/**
 Called each time a handler has been requested. Here is where you can setup the handler with data for the current request.
 
 @param handler the handler that needs to be setup.
 @param view the view that was used to request the handler.
 */
-(void) initHandler:(SIUIViewHandler *) handler withView:(UIView *) view;

@end
