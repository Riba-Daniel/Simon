//
//  SIEventCannon.h
//  Simon
//
//  Created by Derek Clarkson on 21/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The event cannon sits in a background thread and fires events into the application. It's job is to handle both single and sequences of events.
 */
@interface SIUIEventCannon : NSObject {
   @private
   dispatch_queue_t cannonQueue;
   dispatch_queue_t mainQ;
}

/// @name Initialisers

/**
 Default initialiser.
 */
-(id) init;

/**
 Perform the tap sequence on the view.
 */
-(void) tapView:(UIView *) view;

@end
