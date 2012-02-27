//
//  SIUIEventSender.h
//  Simon
//
//  Created by Derek Clarkson on 24/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Class cluster which generates senders for sending events to the application. 
 */
@interface SIUIEventSender : NSObject

/// @name Factory methods.
+(SIUIEventSender *) sender;

/**
 Directly sends an event to the UI.
 
 @param event the event to send.
 */
-(void) sendEvent:(UIEvent *) event;

@end
