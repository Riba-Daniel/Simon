//
//  SIUIAction.h
//  Simon
//
//  Created by Derek Clarkson on 8/08/11.
//  Copyright 2011 Sensis. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 SIUIAction objects can perform UI actions such as taps and swipes on Views.
 */
@interface SIUIAction : NSObject {
	@private 
	UIView *view;
}

/// @name Properties

/**
 The view the action will be performed on.
 */
@property (nonatomic, retain) UIView *view;

/// @name Initialsation

/**
 Initialises the action with the passed view.
 
 @param aView the view the action will be performed against.
 */
-(id) initWithView:(UIView *) aView;

/// @name Tasks

/**
 Perform a tap on the view.
 */
-(void) tap;

@end
