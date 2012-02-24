//
//  SIUITapGenerator.h
//  Simon
//
//  Created by Derek Clarkson on 24/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIUIEventGenerator.h"

/**
 Generates a tap on the specified view.
 */
@interface SIUITapGenerator : NSObject<SIUIEventGenerator>

/// @name Properties

/// The view that will be tapped.
@property (nonatomic, retain) UIView *view;

/// @name INitialiser

/**
 Default initialiser.
 
 @param view the view we are going to tap.
 */
-(id) initWithView:(UIView *) view;

@end
