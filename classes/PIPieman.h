//
//  PieMan.h
//  Simon
//
//  Created by Derek Clarkson on 28/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PIHeartbeatDelegate.h"
#import "PISimulatorDelegate.h"
#import "PIConstants.h"

/**
 This is the main class of Pieman.
 */
@interface PIPieman : NSObject<PIHeartbeatDelegate, PISimulatorDelegate>

/// Set to YES when the tests are finished.
@property (nonatomic, readonly) BOOL finished;

/// The full path to the app to be tested.
@property (nonatomic, retain) NSString *appPath;

/// The device to pass to the simulator.
@property (nonatomic, assign) PIDeviceFamily device;

/// The port that the Pieman will listen on.
@property (nonatomic, assign) NSInteger piemanPort;

/// The port that Simon will be listening on.
@property (nonatomic, assign) NSInteger simonPort;

/// Args for the app.
@property (nonatomic, retain) NSArray *appArgs;

/// The final exit code to be returned to the command line.
@property (nonatomic, readonly) int exitCode;

/// Start the simulator.
-(void) start;

@end
