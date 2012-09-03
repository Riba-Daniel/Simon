//
//  PISimulatorTests.m
//  Simon
//
//  Created by Derek Clarkson on 2/09/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "PISimulator.h"
#import "PIException.h"
#import "PISDKNotFoundException.h"

@interface PISimulatorTests : GHTestCase

@end

@implementation PISimulatorTests

-(void) testAvailableSdks {

	PISimulator *simulator = [[[PISimulator alloc] init] autorelease];
	NSArray *availableSdks = simulator.availableSdkVersions;
	
	GHAssertNotNil(availableSdks, nil);
	GHAssertEquals([availableSdks count], (NSUInteger) 3, nil);
	GHAssertTrue([availableSdks containsObject:@"5.0"], nil);
	GHAssertTrue([availableSdks containsObject:@"5.1"], nil);
	GHAssertTrue([availableSdks containsObject:@"6.0"], nil);
}

-(void) testSdkVersionSetsDefault {
	PISimulator *simulator = [[[PISimulator alloc] init] autorelease];
	GHAssertEqualStrings(simulator.sdkVersion, @"6.0", nil);
}

-(void) testSetSdkVersion {
	PISimulator *simulator = [[[PISimulator alloc] init] autorelease];
	simulator.sdkVersion = @"5.0";
	GHAssertEqualStrings(simulator.sdkVersion, @"5.0", nil);
}

-(void) testSetSdkVersionThrowsIfUnknownVersion {
	PISimulator *simulator = [[[PISimulator alloc] init] autorelease];
	BOOL thrown = NO;
	@try {
		simulator.sdkVersion = @"x.x";
	}
	@catch (NSException *exception) {
		thrown = YES;
		GHAssertEquals([exception class], [PISDKNotFoundException class], nil);
		GHAssertEqualStrings(exception.name, @"PISDKNotFoundException", nil);
		GHAssertEqualStrings(exception.reason, @"No SDK found for version x.x", nil);
	}
	GHAssertTrue(thrown, nil);
}



@end
