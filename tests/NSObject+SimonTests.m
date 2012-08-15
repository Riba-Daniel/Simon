//
//  NSObject+SimonTests.m
//  Simon
//
//  Created by Derek Clarkson on 14/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/NSObject+Simon.h>
@interface NSObject_SimonTests : GHTestCase

@end

@implementation NSObject_SimonTests

-(void) testExecuteOnMainThreadCatchesExceptions {
	BOOL caught = NO;
	@try {
		[self executeBlockOnMainThread:^() {
			@throw [NSException exceptionWithName:@"Fred" reason:@"A reason" userInfo:nil];
		}];
	}
	@catch (NSException *exception) {
		// Good.
		caught = YES;
		GHAssertEqualStrings(exception.name, @"Fred", nil);
	}
	GHAssertTrue(caught, nil);
}

@end
