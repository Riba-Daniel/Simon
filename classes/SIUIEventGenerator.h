//
//  SIUIEventGenerator.h
//  Simon
//
//  Created by Derek Clarkson on 24/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

/**
 Classes which can generate one or more events to be sent to the interface. Implementations of this interface define the events in order to create taps, swipes and other gestures.
 */
@protocol SIUIEventGenerator <NSObject>

/// @name Tasks

/**
 Create and send the events.
 */
-(void) sendEvents;

@end
