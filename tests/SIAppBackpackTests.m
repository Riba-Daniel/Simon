//
//  SIAppBackpackTests.m
//  Simon
//
//  Created by Derek Clarkson on 5/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>

#import <Simon/SIAppBackpack.h>
#import <Simon/SIConstants.h>

@interface SIAppBackpackTests : GHTestCase

@end

@implementation SIAppBackpackTests

-(void) testStartupLoadsStories {
	
	SIAppBackpack *backpack = [[[SIAppBackpack alloc] init] autorelease];
	NSNotification *notification = [NSNotification notificationWithName:UIApplicationDidBecomeActiveNotification object:self];
	
	[backpack startUp:notification];
	
	GHAssertTrue(backpack.storySources > 0, nil);
	
}


@end
