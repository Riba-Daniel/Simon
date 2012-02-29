//
//  SIUIEventSender.h
//  Simon
//
//  Created by Derek Clarkson on 24/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Class cluster which generates senders for sending events to the application. At the moment this is one of two classes. A background sender for sending events from a background thread, or a main thread sender if the current thread is the main thread. This enables the generators to send events without worrying about which thread they are sending from.
 */
@interface SIUIEventSender : NSObject

/// @name Factory methods.

/**
 Generates an apropriate instance of SIUIEventSender and returns it.
 
 @return an instance of SIUIEventSender.
 */
+(SIUIEventSender *) sender;

/**
 Directly sends an event to the UI.
 
 @param event the event to send.
 */
-(void) sendEvent:(UIEvent *) event;

@end
