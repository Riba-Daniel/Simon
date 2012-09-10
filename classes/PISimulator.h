//
//  PISimulator.h
//  Simon
//
//  Created by Derek Clarkson on 2/09/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "SICore.h"
#import "PIConstants.h"
#import "DTiPhoneSimulatorSessionDelegate.h"
#import "PISimulatorDelegate.h"

/**
 Wrapper for the private frameworks which manage the simulator. This code is based heavily on the WaxSim code at https://github.com/probablycorey/WaxSim
 which I used to see how to run the simulator.
 */
@interface PISimulator : NSObject<DTiPhoneSimulatorSessionDelegate>

/// @name Properties

/// The delegate which watches this simulator.
@property (nonatomic, assign) id<PISimulatorDelegate> delegate;

/// Path to the application binary to be launched.
@property (nonatomic, readonly) NSString *appPath;

/// Returns a list of the available SDKs in the system.
@property (nonatomic, readonly) NSArray *availableSdkVersions;

/**
 Gets/Sets the version of the SDK that will be used.
 
 @throws PISDKNotFoundException if there is no SDK for the passed version.
*/
@property (nonatomic, assign) NSString *sdkVersion;

/// What device to simulate. Defaults to the iPhone.
@property (nonatomic, assign) PIDeviceFamily deviceFamily;

/// App arguments.
@property (nonatomic, retain) NSArray *args;

/// Environment settings.
@property (nonatomic, retain) NSDictionary *environment;

/// @name Initialisation

/**
 Default initialiser that takes a path to the app.
 
 @param appPath a path to the compiled application which is to be installed into the simulator.
 @return an instance of this class.
 */
-(id) initWithApplicationPath:(NSString *) appPath;

/// @name Tasks

/**
 Starts the simulator and loads the app into it.
 */
-(void) launch;

/**
 Shut down the app, simulator and exit.
 */
-(void) shutdown;

/**
 Can be called just to shutdown the simulator if it is running. Once done, the finish block is run.
 
 @param finishedShutdownBlock a block which is executed once the simulator has been shutdown.
 */
-(void) shutdownSimulator:(SimpleBlock) finishedShutdownBlock;

/**
 Resets and re-launches the simulator.
 */
-(void) reset;

@end
