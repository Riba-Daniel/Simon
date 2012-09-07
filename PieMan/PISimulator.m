//
//  PISimulator.m
//  Simon
//
//  Created by Derek Clarkson on 2/09/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "DTiPhoneSimulatorApplicationSpecifier.h"
#import "DTiPhoneSimulatorSessionConfig.h"
#import "DTiPhoneSimulatorSystemRoot.h"
#import "DTiPhoneSimulatorSession.h"

#import "PISimulator.h"
#import "PISDKNotFoundException.h"
#import "PIException.h"
#import "DTiPhoneSimulatorSession+Pieman.h"

#import <AppKit/AppKit.h>

#import <dUsefulStuff/NSObject+dUsefulStuff.h>
#import <dUsefulStuff/DCCommon.h>

#import "PIConstants.h"

@interface PISimulator () {
@private
	DTiPhoneSimulatorSystemRoot *selectedSdk;
	NSString *_appPath;
	NSTimeInterval secondsSinceTerminationRequest;
	NSRunningApplication *simulator;
	DTiPhoneSimulatorSession* session;
}

@property (nonatomic, copy) SimpleBlock postShutdownBlock;


-(BOOL) delegateHandlesSelector:(SEL) selector;
-(void) checkForSimulatorTermination;
-(void) finishShutdown;

@end

@implementation PISimulator

@synthesize delegate = _delegate;
@synthesize appPath = _appPath;
@synthesize deviceFamily = _deviceFamily;
@synthesize args = _args;
@synthesize environment = _environment;
@synthesize postShutdownBlock = _postShutdownBlock;

@dynamic availableSdkVersions;
@dynamic sdkVersion;

-(void) dealloc {
	DC_DEALLOC(_appPath);
	self.args = nil;
	self.environment = nil;
	self.postShutdownBlock = nil;
	DC_DEALLOC(selectedSdk);
	DC_DEALLOC(session);
	[super dealloc];
}

-(id) initWithApplicationPath:(NSString *) appPath {
	self = [super init];
	if (self) {
		_appPath = [appPath retain];
		selectedSdk = [[DTiPhoneSimulatorSystemRoot defaultRoot] retain];
		self.deviceFamily = PIDeviceFamilyiPhone;
	}
	return self;
}

#pragma mark - Running

-(void) launch {
	
	// Clear the delegate so that the shutdown doesn't send messages.
	DC_LOG(@"Launching simulator");
	
	// Setup an app specifier.
	DTiPhoneSimulatorApplicationSpecifier *appSpec = [DTiPhoneSimulatorApplicationSpecifier specifierWithApplicationPath:self.appPath];
	if (!appSpec) {
		@throw [PIException exceptionWithReason:[NSString stringWithFormat:@"Error loading app from %@", self.appPath]];
	}
	
	// Setup the session config.
	DC_LOG(@"Creating config for %@", self.appPath);
	DTiPhoneSimulatorSessionConfig *config = [[[DTiPhoneSimulatorSessionConfig alloc] init] autorelease];
	
	[config setLocalizedClientName:@"Pieman"];
	[config setApplicationToSimulateOnStart:appSpec];
	[config setSimulatedSystemRoot:selectedSdk];
	[config setSimulatedDeviceFamily:[NSNumber numberWithInt:self.deviceFamily]];
	[config setSimulatedApplicationShouldWaitForDebugger:NO];
	[config setSimulatedApplicationLaunchArgs:self.args];
	[config setSimulatedApplicationLaunchEnvironment:self.environment];
	
	// Setup the session.
	DC_LOG(@"Creating session");
	session = [[DTiPhoneSimulatorSession alloc] init];
	[session setDelegate:self];
	
	// and lauch the simulator.
	DC_LOG(@"Launching");
	NSError *error;
	if (![session requestStartWithConfig:config timeout:SESSION_TIMEOUT error:&error]) {
		@throw [PIException exceptionWithReason:[NSString stringWithFormat:@"Error launching simulator: %@", [error localizedFailureReason]]];
	}
	
	DC_LOG(@"Launched");
	if ([self delegateHandlesSelector:@selector(simulatorDidStart:)]) {
		[self.delegate simulatorDidStart:self];
	}
	
}

-(void) reset {
	
	DC_LOG(@"Resetting content");
	
	// Reset by deleting the content directory.
	NSString *contentPath = [[NSString stringWithFormat:SIMULATOR_CONTENT_PATH, self.sdkVersion] stringByExpandingTildeInPath];
	NSError *error = nil;
	DC_LOG(@"Removing simulator content directory: %@", contentPath);
	if ([[NSFileManager defaultManager] fileExistsAtPath:contentPath]
		 && ![[NSFileManager defaultManager] removeItemAtPath:contentPath error:&error]) {
		DC_LOG(@"Removing simulator content directory failed: %@", error.localizedFailureReason);
		@throw [PIException exceptionWithReason:[NSString stringWithFormat:@"Error simulator working directory: %@", [error localizedFailureReason]]];
	}
	
}

#pragma mark - Termination

-(void) shutdown {
	if (session != nil) {
		DC_LOG(@"Shutdown requested, telling session to end.");
		[session requestEndWithTimeout:SESSION_TIMEOUT];
	} else {
		[self shutdownSimulator:nil];
	}
}

-(void) shutdownSimulator:(SimpleBlock) finishedShutdownBlock {
	
	self.postShutdownBlock = finishedShutdownBlock;
	
	// Find the running simulator.
	DC_LOG(@"Looking for a running simulator");
	NSArray *sims = [NSRunningApplication runningApplicationsWithBundleIdentifier:APPLE_SIMULATOR_BUNDLE_ID];
	if ([sims count] == 0) {
		DC_LOG(@"No simulator running");
		[self finishShutdown];
		return;
	}
	
	simulator = [[sims objectAtIndex:0] retain];
	if (simulator.terminated) {
		
		// Simulator not running so tell the delegate.
		DC_LOG(@"Simulator is already terminated");
		[self finishShutdown];
		
	} else {
		
		DC_LOG(@"Running simulator found (%@), shutting it down.", simulator.localizedName);
		[simulator terminate];
		secondsSinceTerminationRequest = 0;
		[self performSelector:@selector(checkForSimulatorTermination) withObject:self afterDelay:TERMINATION_CHECK_PERIOD];
		
	}
	
}

-(void) checkForSimulatorTermination {
	
	secondsSinceTerminationRequest++;
	DC_LOG(@"Checking to see if simulator has terminated, seconds %f", secondsSinceTerminationRequest);
	if ([simulator isTerminated]) {
		
		DC_LOG(@"Simulator is now terminated.");
		[self finishShutdown];
		return;
	}
	
	// If we have waited beyond reason, hard kill the simulator.
	if (secondsSinceTerminationRequest >= FORCE_TERMINATE_AFTER) {
		DC_LOG(@"Simulator still not terminated, forcing termination.");
		[simulator forceTerminate];
		[self finishShutdown];
		return;
	}
	
	// Otherwise requeue this method.
	DC_LOG(@"Simulator not terminated after %f seconds, waiting.", secondsSinceTerminationRequest);
	[self performSelector:@selector(checkForSimulatorTermination) withObject:self afterDelay:TERMINATION_CHECK_PERIOD];
	
}

-(void) finishShutdown {
	DC_LOG(@"Simulator has shutdown, finalising.");
	DC_DEALLOC(simulator);
	DC_DEALLOC(session);
	
	if ([self delegateHandlesSelector:@selector(simulatorDidEnd:)]) {
		DC_LOG(@"Notifying delegate");
		[self.delegate simulatorDidEnd:self];
	}
	
	if (self.postShutdownBlock != nil) {
		DC_LOG(@"Executing passed post shutdown block");
		self.postShutdownBlock();
		self.postShutdownBlock = nil;
	}
	
	// Now post the the current run loop to trigger Pieman's shutdown.
}

#pragma mark - Simulator delegate

- (void)session:(DTiPhoneSimulatorSession *)session didStart:(BOOL)started withError:(NSError *)error {
	
	DC_LOG(@"App session started: %@", DC_PRETTY_BOOL(started));
	if (!started) {
		DC_LOG(@"Session failed to start. Error code: %li", [error code]);
		// Notify the delegate.
		if ([self delegateHandlesSelector:@selector(simulator:appDidFailToStartWithError:)]) {
			[self.delegate simulator:self appDidFailToStartWithError: error];
		}
		
		// shutdown the simulator.
		[self shutdownSimulator:nil];
		return;
	}
	
	// Notify the delegate.
	DC_LOG(@"Session started");
	if ([self delegateHandlesSelector:@selector(simulatorAppDidStart:)]) {
		[self.delegate simulatorAppDidStart:self];
	}
	
}

- (void)session:(DTiPhoneSimulatorSession *)session didEndWithError:(NSError *)error {
	
	DC_LOG(@"App session ended");
	NSError *finalError = error;
	if (error != nil) {
		DC_LOG(@"App session ended with error: %@", [error localizedFailureReason]);
		
		// We want to ignore timeouts because they will be triggered by shutdowns and restarts.
		if ([error code] == 2) {
			DC_LOG(@"But ignoring timeout error.");
			finalError = nil;
		}
	}
	
	// Notify the delegate.
	if ([self delegateHandlesSelector:@selector(simulator:appDidEndWithError:)]) {
		[self.delegate simulator:self appDidEndWithError: finalError];
	}
	
	// Shutdown the simulator itself.
	[self shutdownSimulator:nil];
	
}

-(void) sessionWillEnd:(id)arg1 {
	DC_LOG(@"App about to end");
}

-(BOOL) delegateHandlesSelector:(SEL) selector {
	return (self.delegate != nil && [self.delegate respondsToSelector:selector]);
}


#pragma mark - Dynamic properties.

-(NSString *) sdkVersion {
	return selectedSdk.sdkVersion;
}

-(void) setSdkVersion:(NSString *) sdkVersion {
	
	// first verify the version.
	DTiPhoneSimulatorSystemRoot *newVersion = [[DTiPhoneSimulatorSystemRoot rootWithSDKVersion:sdkVersion] retain];
	if (newVersion == nil) {
		@throw [PISDKNotFoundException exceptionWithReason:[NSString stringWithFormat:@"No SDK found for version %@", sdkVersion]];
	}
	
	DC_DEALLOC(selectedSdk);
	selectedSdk = newVersion;
}

-(NSArray *) availableSdkVersions {
	NSMutableArray *sdks = [NSMutableArray array];
	for (id root in [DTiPhoneSimulatorSystemRoot knownRoots]) {
		DC_LOG(@"Found SDK: %2$@, version %3$@ at %1$@", [root sdkRootPath], [root sdkDisplayName], [root sdkVersion]);
		[sdks addObject:[root sdkVersion]];
	}
	return sdks;
}

@end
