//
//  NSObject+Simon.m
//  Simon
//
//  Created by Derek Clarkson on 21/03/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>

#import <Simon/NSObject+Simon.h>
#import <Simon/SIAppBackpack.h>

/**
 General functions which are called from all sorts of places.
 */
@implementation NSObject (Simon)

-(void) executeBlockOnMainThread:(void (^)()) block {
	if (dispatch_get_current_queue() == dispatch_get_main_queue()) {
		// Direct execution.
		DC_LOG(@"Already on main thread, executing");
		block();
	} else {
		// Goto the main Q.
		DC_LOG(@"Dispatching to main thread");
		__block NSException *exception = nil;
		dispatch_queue_t mainQ = dispatch_get_main_queue();
		dispatch_sync(mainQ, ^{
			@try {
				block();
			}
			@catch (NSException *e) {
				DC_LOG(@"Exception caught: %@", e);
				exception = [e retain];
			}
		});
		if (exception != nil) {
			DC_LOG(@"throwing exception");
			@throw [exception autorelease];
		}
	}
}

-(void) executeOnSimonThread:(void (^)()) block {
	
	// Async call so no need to catch exceptions.
	dispatch_async([SIAppBackpack backpack].queue, ^{
		DC_LOG(@"Executing block on Simon's background thread");
		block();
	});
	
}

@end
