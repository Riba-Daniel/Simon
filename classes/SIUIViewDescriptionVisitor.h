//
//  SIUIViewDescriptionVisitor.h
//  Simon
//
//  Created by Derek Clarkson on 9/03/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Simon/SIUIViewDescriptionVisitorDelegate.h>

/**
 Class which visits each node in a UI tree, gathers information about that node and then notifies a delegate of what it found.
 */
@interface SIUIViewDescriptionVisitor : NSObject {
	@private
	NSObject<SIUIViewDescriptionVisitorDelegate> *delegate;
}

/// @name Initialisers

/**
 Default initialiser which takes a delegate. This will be a weak reference because it is assumed that the delegate is likely to be the class that created this class and is assumed to 
 exist for a longer period of time. This is standard with Apple code.
 
 @param aDelegate an instance of a class that implements the SIUIViewDescriptionVisitorDelegate protocol.
 */
-(id) initWithDelegate:(NSObject<SIUIViewDescriptionVisitorDelegate> *) aDelegate;

/// @name Tasks

/**
 Visits the view and all of it's subviews.

 @param view the view to start from.
 */
-(void) visitView:(UIView *) view;

/**
 Gets all the windows from the Application and visits them all. This includes keyboards which are added as a separate window.
 */
-(void) visitAllWindows;

@end
