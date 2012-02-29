//
//  SIUIMainThreadSender.h
//  Simon
//
//  Created by Derek Clarkson on 25/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIUIEventSender.h"

/**
 Sender usd when sending events from the main thread. Not really recommended, but can happen. This attempts to make it invisible to the test code.
 */
@interface SIUIMainThreadSender : SIUIEventSender

/// Default initialiser.
-(id) init;

@end
