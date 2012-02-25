//
//  SIEventCannon.h
//  Simon
//
//  Created by Derek Clarkson on 21/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIUIEventSender.h"

@interface SIUIBackgroundThreadSender : SIUIEventSender {
   @private
   dispatch_queue_t mainQ;
}

-(id) init;

@end
