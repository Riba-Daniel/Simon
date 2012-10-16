//
//  PIHeartbeatDelegate.h
//  Simon
//
//  Created by Derek Clarkson on 29/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Allows something to respond to heatbeat events.
*/
@protocol PIHeartbeatDelegate <NSObject>

@optional

/// @name Tasks

/// Called when the heartbeat has started.
-(void) heartbeatDidStart;

/// The heartbeat timed out.
-(void) heartbeatDidTimeout;

@end
