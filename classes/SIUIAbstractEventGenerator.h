//
//  SIUIAbstractEventGenerator.h
//  Simon
//
//  Created by Derek Clarkson on 17/03/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Abstract parent class of event generators. This class provides basic infrastructure for the actual generators. It creates and stores the touch and event objects so 
 that the handling of these objects is centralised and done correctly.
 */
@interface SIUIAbstractEventGenerator : NSObject {
	@protected
	__block UITouch *touch;
	__block UIEvent *event;
}

/// @name Properties

/// The view that will be tapped.
@property (nonatomic, retain) UIView *view;

/// @name INitialiser

/**
 Default initialiser.
 
 @param view the view we are going to tap.
 */
-(id) initWithView:(UIView *) view;

/// @name Tasks

/**
 Create and send the events. This is the main method to call from external classes.
 */
-(void) generateEvents;

/**
 Directly sends the event to the UI. Internal method.
 */
-(void) sendEvent;


@end
