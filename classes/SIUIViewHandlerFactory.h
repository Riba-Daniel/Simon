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

/// @name Tasks

/**
 Call this method to obtain a handler for a view. This method manages the creation and caching of handlers and calls createHandlerForView: to obtain new handlers as necessary.
 
 @param view the view we need the handler for.
 */
-(SIUIViewHandler *) handlerForView:(UIView<DNNode> *) view;

/**
 This does the work of creating a handler. If you want to create a custom implementation of this class to create your own handlers. Override this method to do the creation. Like all create methods this should return an autoreleased object. Note that this will only be called once per view class as handlers are cached and reused.
 
 @param view the view we want to obtain a handler for.
 @result the appropriate handler.
 */
-(SIUIViewHandler *) createHandlerForView:(UIView<DNNode> *) view;

@end
