//
//  SIEventCannon.h
//  Simon
//
//  Created by Derek Clarkson on 21/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIUIEventSender.h"

/**
 Sender used when sending events from a background thread.
 */
@interface SIUIBackgroundThreadSender : SIUIEventSender {
   @private
   dispatch_queue_t mainQ;
}

/// Main init.
-(id) init;

@end
