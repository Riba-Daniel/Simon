//
//  SIActionFactory.h
//  Simon
//
//  Created by Derek Clarkson on 8/08/11.
//  Copyright 2011. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SIUIAction.h"

/**
 This factory creates instances of SIAction that can perform actions such as taps and swipes on controls.
 This faction also provides the extension point for handling. ou can extend it and override it's methods to intercept and return your custom SIUIAction classes. Just don't
 forget to call the super version as well.
 
 The easiest way to do this is to create a Category on this factory which overrides the createFactory method and returns your extension of this class. Then import 
 */
@interface SIUIActionFactory : NSObject {
	@private
}

/// @name Factory

/**
 Sets a new factory for creating actions. Normamly you would not use this unless you want to extend the SIUIActionFactory class to implement your own factory methods.
 
 @param actionFactory the new factory to set. 
 */
+(void) setActionFactory:(SIUIActionFactory *) actionFactory;

/**
 Returns the current factory instance. If it is nil, then an instance of SIUIActionFactory is created first.
 */
+(SIUIActionFactory *) actionFactory;


/// @name Tasks

/**
 Factory method for creating a SIUIAction object for a specific view.
 */
-(SIUIAction *) createActionForView:(UIView *) view;

@end
