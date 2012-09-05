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

#import <Simon/SIConstants.h>

#define TERMINATION_CHECK_PERIOD 1.0
#define FORCE_TERMINATE_AFTER 5.0
#define SESSION_TIMEOUT 30.0

@interface PISimulator () {
@private
	DTiPhoneSimulatorSystemRoot *selectedSdk;
	NSString *_appPath;
	NSTimeInterval secondsSinceTerminationRequest;
	NSRunningApplication *simulator;
}

@property (nonatomic, retain) DTiPhoneSimulatorSession* session;

-(void) shutdownSimulator;
-(BOOL) delegateHandlesSelector:(SEL) selector;
-(void) checkForSimulatorTermination;

@end

@implementation PISimulator

@synthesize delegate = _delegate;
@synthesize appPath = _appPath;
@synthesize deviceFamily = _deviceFamily;
@synthesize args = _args;
@synthesize environment = _environment;
@synthesize session = _session;

@dynamic availableSdkVersions;
@dynamic sdkVersion;

-(void) dealloc {
	DC_DEALLOC(_appPath);
	self.args = nil;
	self.environment = nil;
	self.session = nil;
	DC_DEALLOC(selectedSdk);
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

-(void) launch {
	
	// Setup an app specifier.
	DTiPhoneSimulatorApplicationSpecifier *appSpec = [DTiPhoneSimulatorApplicationSpecifier specifierWithApplicationPath:self.appPath];
	if (!appSpec) {
		@throw [PIException exceptionWithReason:[NSString stringWithFormat:@"Error loading app from %@", self.appPath]];
	}
	
	// Setup the session config.
	DC_LOG(@"Creating config");
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
	self.session = [[[DTiPhoneSimulatorSession alloc] init] autorelease];
	[self.session setDelegate:self];
	
	// and lauch the simulator.
	DC_LOG(@"Launching");
	NSError *error;
	if (![self.session requestStartWithConfig:config timeout:SESSION_TIMEOUT error:&error]) {
		@throw [PIException exceptionWithReason:[NSString stringWithFormat:@"Error launching simulator: %@", [error localizedFailureReason]]];
	}
	DC_LOG(@"Launched");
	
	if ([self delegateHandlesSelector:@selector(simulatorDidStart:)]) {
		[self.delegate simulatorDidStart:self];
	}
	
}

#pragma mark - Termination

-(void) shutdown {
	DC_LOG(@"requesting shutdown of app and simulator");
	[self.session requestEndWithTimeout:SESSION_TIMEOUT];
	
	// Shutdown the simulator itself.
	[self shutdownSimulator];
	
	self.session = nil;
}

-(void) shutdownSimulator {
	
	// Get the process data from the system.
	ProcessSerialNumber processSerialNumber = self.session.processSerialNumber;
	CFDictionaryRef processInfoDict = ProcessInformationCopyDictionary(&processSerialNumber, kProcessDictionaryIncludeAllInformationMask);
	
	if (processInfoDict == nil) {
		
		// Simulator not running so tell the delegate.
		if ([self delegateHandlesSelector:@selector(simulatorDidEnd:)]) {
			[self.delegate simulatorDidEnd:self];
		}
		return;
	}
	
	// Extract the pid from the data.
	CFNumberRef pidNumberRef = CFDictionaryGetValue(processInfoDict, CFSTR("pid"));
	pid_t pid;
	CFNumberGetValue(pidNumberRef, kCFNumberSInt32Type, &pid);
	CFRelease(processInfoDict);
	
	// Get the application reference and send it a terminate message.
	simulator = [[NSRunningApplication runningApplicationWithProcessIdentifier:pid] retain];
	if (simulator == nil || simulator.terminated) {
		
		// Simulator not running so tell the delegate.
		if ([self delegateHandlesSelector:@selector(simulatorDidEnd:)]) {
			[self.delegate simulatorDidEnd:self];
		}
		
	} else {
		
		DC_LOG(@"Running simulator found (%@) on pid %i, shutting it down.", simulator.localizedName, pid);
		[simulator terminate];
		secondsSinceTerminationRequest = 0;
		[self performSelector:@selector(checkForSimulatorTermination) withObject:self afterDelay:TERMINATION_CHECK_PERIOD];
		
	}
}

-(void) checkForSimulatorTermination {
	
	DC_LOG(@"Checking simulator");
	if ([simulator isTerminated]) {
		
		DC_LOG(@"Simulator terminated.");
		DC_DEALLOC(simulator);
		if ([self delegateHandlesSelector:@selector(simulatorDidEnd:)]) {
			[self.delegate simulatorDidEnd:self];
		}
		
	} else {
		
		// If we have waited beyond reason, hard kill the simulator.
		if (secondsSinceTerminationRequest >= FORCE_TERMINATE_AFTER) {
			DC_LOG(@"Simulator still alive, force terminating it.");
			[simulator forceTerminate];
			DC_DEALLOC(simulator);
		} else {
			
			// Otherwise requeue this method.
			secondsSinceTerminationRequest++;
			DC_LOG(@"Simulator not terminated after %f seconds, waiting.", secondsSinceTerminationRequest);
			[self performSelector:@selector(checkForSimulatorTermination) withObject:self afterDelay:TERMINATION_CHECK_PERIOD];
		}
		
	}
	
}

#pragma mark - Simulator delegate

- (void)session:(DTiPhoneSimulatorSession *)session didStart:(BOOL)started withError:(NSError *)error {
	DC_LOG(@"App started: %@", DC_PRETTY_BOOL(started));
	if (!started) {
		DC_LOG(@"Session failed to start. Code: %lu, message: %@", [error code], [error localizedDescription]);
		// Notify the delegate.
		if ([self delegateHandlesSelector:@selector(simulator:appDidFailToStartWithError:)]) {
			[self.delegate simulator:self appDidFailToStartWithError: error];
		}
	} else {
		// Notify the delegate.
		if ([self delegateHandlesSelector:@selector(simulatorAppDidStart:)]) {
			[self.delegate simulatorAppDidStart:self];
		}
	}
}

- (void)session:(DTiPhoneSimulatorSession *)session didEndWithError:(NSError *)error {
	DC_LOG(@"App ended");
	if (error) {
		DC_LOG(@"Session ended with error. %@", [error localizedDescription]);
		// if ([error code] != 2) exit(1); // if it is a timeout error, that's cool. We are probably rebooting
	} else {
		// Exit
	}
	
	// Notify the delegate.
	if ([self delegateHandlesSelector:@selector(simulator:appDidEndWithError:)]) {
		[self.delegate simulator:self appDidEndWithError: error];
	}
	
	// Queue a shutdown of the simulator.
	[self shutdown];
	
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
