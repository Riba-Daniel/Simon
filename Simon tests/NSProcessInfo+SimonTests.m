//
//  NSObject+SimonCmdArgsTests.m
//  Simon
//
//  Created by Derek Clarkson on 11/09/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/NSProcessInfo+Simon.h>

// Hack into the process to update arguments for testing.
@interface NSProcessInfo (SIAppBackpackTests)
- (void)setArguments:(id)arg1;
@end

@interface NSProcessInfo_SimonTests : GHTestCase {
	@private
	NSProcessInfo *info;
	NSArray *originalArgs;
}

@end

@implementation NSProcessInfo_SimonTests 
-(void) setUp {
	info = [[NSProcessInfo processInfo] retain];
	originalArgs = [[info arguments] retain];
}

-(void) tearDown {
	[[NSProcessInfo processInfo] setArguments: originalArgs];
	DC_DEALLOC(originalArgs);
	DC_DEALLOC(info);
}

-(void) testPresenceOfArg {
	NSArray *args = [NSArray arrayWithObjects:@"-hello", nil];
	[info setArguments:args];
	GHAssertTrue([info isArgumentPresentWithName:@"-hello"], nil);
}

-(void) testRetrieveArgValue {
	NSArray *args = [NSArray arrayWithObjects:@"-hello", @"abc", nil];
	[info setArguments:args];
	GHAssertTrue([info isArgumentPresentWithName:@"-hello"], nil);
	NSString *argValue = [info argumentValueForName:@"-hello"];
	GHAssertEqualStrings(argValue, @"abc", nil);
}

-(void) testRetrieveArgValueNilWhenNotPresent {
	NSArray *args = [NSArray arrayWithObjects:@"-hello", nil];
	[info setArguments:args];
	GHAssertTrue([info isArgumentPresentWithName:@"-hello"], nil);
	NSString *argValue = [info argumentValueForName:@"-hello"];
	GHAssertNil(argValue, nil);
}

-(void) testRetrieveArgValueNilWhenValueIsNextArg {
	NSArray *args = [NSArray arrayWithObjects:@"-hello", @"-there", nil];
	[info setArguments:args];
	GHAssertTrue([info isArgumentPresentWithName:@"-hello"], nil);
	NSString *argValue = [info argumentValueForName:@"-hello"];
	GHAssertNil(argValue, nil);
}

@end
