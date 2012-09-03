//
//  PISimulator.h
//  Simon
//
//  Created by Derek Clarkson on 2/09/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Wrapper for the private frameworks which manage the simulator. This code is based heavily on the WaxSim code at https://github.com/probablycorey/WaxSim
 which I used to see how to run the simulator.
 */
@interface PISimulator : NSObject

/// @name Properties

/// Path to the application binary to be launched.
@property (nonatomic, retain) NSString *appPath;

/// Returns a list of the available SDKs in the system.
@property (nonatomic, readonly) NSArray *availableSdkVersions;

/**
 Gets/Sets the version of the SDK that will be used.
 
 @throws PISDKNotFoundException if there is no SDK for the passed version.
*/
@property (nonatomic, assign) NSString *sdkVersion;

/**
 Starts the simulator and loads the app into it.
 */
-(void) launch;

@end
