//
//  SIUIEventGenerator.h
//  Simon
//
//  Created by Derek Clarkson on 24/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

/**
 Classes which can generate one or more events to be sent to the interface.
 */
@protocol SIUIEventGenerator <NSObject>

/// @name Tasks

/**
 Called by the cannon to tell the generator to create and send the events.
 */
-(void) sendEvents;

@end
