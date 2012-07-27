//
//  NSObject+Simon.m
//  Simon
//
//  Created by Derek Clarkson on 21/03/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "NSObject+Simon.h"
#import <dUsefulStuff/DCCommon.h>

/**
 General functions which are called from all sorts of places.
 */
@implementation NSObject (Simon)

-(void) executeBlockOnMainThread:(void (^)()) block {
	if ([NSThread isMainThread]) {
		// Direct execution.
		DC_LOG(@"Executing on main thread");
		block();
	} else {
		// Goto the main Q.
		DC_LOG(@"Dispatching to main thread");
		dispatch_queue_t mainQ = dispatch_get_main_queue();
		dispatch_sync(mainQ, ^{
			block();
		});
	}
}

@end
