//
//  PIHeartbeat.h
//  Simon
//
//  Created by Derek Clarkson on 29/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "PIHeartbeatDelegate.h"

/**
 This class acts as a heartbeat for Simon on the simulator, periodically checking it to see if it's alve.
 */
@interface PIHeartbeat : NSObject

/// @name Properties

/// A delegate which is told of heatbeat events.
@property (nonatomic, assign) NSObject<PIHeartbeatDelegate> *delegate;

/// @name Tasks

/// Starts the heartbeat.
-(void) start;

/// Stops the heartbeat.
-(void) stop;

@end
