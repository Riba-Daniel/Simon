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
 This faction also provides the extension point for handling. You can extend it and override it's methods to intercept and return your custom SIUIAction classes. Just don't
 forget to call the super version as well.
 
 The easiest way to do this is to create a Category on this factory which overrides the createFactory method and returns your extension of this class. 
 */
@interface SIUIViewHandlerFactory : NSObject 

/// @name Factory

/// @name Tasks

/**
 Call this method to obtain a handler for a view. If you want to create a custom implementation of this class to create your own handlers. 
 Override this method to do the creation. Like all create methods this should return an autoreleased object. 
 
 @param view the view we need the handler for.
 */
-(SIUIViewHandler *) handlerForView:(UIView<DNNode> *) view;

@end
