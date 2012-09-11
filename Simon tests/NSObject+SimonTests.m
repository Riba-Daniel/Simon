//
//  NSObject+SimonTests.m
//  Simon
//
//  Created by Derek Clarkson on 14/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/NSObject+Simon.h>
#import <Simon/SIAppBackpack.h>

@interface NSObject_SimonTests : GHTestCase {
@private
	dispatch_queue_t testQ;
}

@end

@implementation NSObject_SimonTests

-(void) setUp {
	testQ = dispatch_queue_create("au.com.derekclarkson.simon.testing", NULL);
}

-(void) tearDown {
	dispatch_release(testQ);
	testQ = NULL;
}


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

-(void) testExecuteOnSimonThreadIsOnBackgroundThread {

	[SIAppBackpack setBackpack:[[[SIAppBackpack alloc] init] autorelease]];
	[SIAppBackpack backpack].queue = testQ;
	
	NSThread *testThread = [NSThread currentThread];
	__block BOOL executed = NO;
	[self executeOnSimonThread:^{
		GHAssertNotEquals([NSThread currentThread], testThread, nil);
		executed = YES;
	}];
	
	// give it some time to execute and then test it did.
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	[NSThread sleepForTimeInterval:0.2];
	GHAssertTrue(executed, nil);
	
}

@end
