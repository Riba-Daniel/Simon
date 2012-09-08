//
//  PISimulatorDelegate.h
//  Simon
//
//  Created by Derek Clarkson on 5/09/12.
//  Copyright (c) 2012. All rights reserved.
//

@class PISimulator;

/**
 Protocol for responding to the simulator events.
 */
@protocol PISimulatorDelegate <NSObject>

@optional

/// @Tasks

/**
 Called after the simulator has been started.
 
 @param simulator the simulator instance.
 
 */
-(void) simulatorDidStart:(PISimulator *) simulator;

/**
 Called after the simulator has been shutdown.
 
 @param simulator the simulator instance.
 
 */
-(void) simulatorDidEnd:(PISimulator *) simulator;

/**
 Called after the app has been started.
 
 @param simulator the simulator instance.
 
 */
-(void) simulatorAppDidStart:(PISimulator *) simulator;

/**
 Called after the app session has ended.
 
 @param simulator the simulator instance.
 @param error if an error occured then this will be populated, otherwise nil.
 
 */
-(void) simulator:(PISimulator *) simulator appDidEndWithError:(NSError *) error;

/**
 Called if the app fails to start.
 
 @param simulator the simulator instance.
 @param error the returned error instance.
 
 */
-(void) simulator:(PISimulator *) simulator appDidFailToStartWithError:(NSError *) error;

@end
