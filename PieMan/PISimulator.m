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

#import "PISimulator.h"
#import "PISDKNotFoundException.h"
#import "PIException.h"

#import <dUsefulStuff/NSObject+dUsefulStuff.h>
#import <dUsefulStuff/DCCommon.h>

#import <Simon/SIConstants.h>

@interface PISimulator () {
	@private
	DTiPhoneSimulatorSystemRoot *selectedSdk;
}

@end

@implementation PISimulator

@synthesize appPath = _appPath;

@dynamic availableSdkVersions;
@dynamic sdkVersion;

-(void) dealloc {
	self.appPath = nil;
	DC_DEALLOC(selectedSdk);
	[super dealloc];
}

-(id) init {
	self = [super init];
	if (self) {
		
	}
	return self;
}

-(void) launch {
	
	// Setup an app specifier.
	DTiPhoneSimulatorApplicationSpecifier *appSpec = [DTiPhoneSimulatorApplicationSpecifier specifierWithApplicationPath:_appPath];
	if (!appSpec) {
		@throw [PIException exceptionWithReason:[NSString stringWithFormat:@"Error loading app from %@", _appPath]];
	}
	
	// Setup the session config.
	DTiPhoneSimulatorSessionConfig *config = [[DTiPhoneSimulatorSessionConfig alloc] init];
	[config setApplicationToSimulateOnStart:appSpec];
	/**
	[config setSimulatedSystemRoot:_sdk];
	[config setSimulatedDeviceFamily:_family];
	[config setSimulatedApplicationShouldWaitForDebugger:NO];
	[config setSimulatedApplicationLaunchArgs:_args];
	[config setSimulatedApplicationLaunchEnvironment:_env];
	[config setLocalizedClientName:@"Pieman"];
*/
}

#pragma mark - Dynamic properties.

-(NSString *) sdkVersion {
	if (selectedSdk == nil) {
		selectedSdk = [[DTiPhoneSimulatorSystemRoot defaultRoot] retain];
	}
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
