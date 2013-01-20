//
//  SIUIApplication+Time.m
//  Simon
//
//  Created by Derek Clarkson on 4/01/13.
//  Copyright (c) 2013 Sensis. All rights reserved.
//

#import <Simon/SIUIApplication+Time.h>
#import <Simon/SIUIApplication+Searches.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIUIException.h>
#import <QuartzCore/QuartzCore.h>

@interface SIUIApplication (_internalTime)
-(BOOL) animationsRunningOnViewHierarchy:(UIView *) view;
@end

@implementation SIUIApplication (Time)
-(void) pauseFor:(NSTimeInterval) duration {
   [NSThread sleepForTimeInterval:duration];
}

-(UIView *) waitForViewWithQuery:(NSString *) query retryInterval:(NSTimeInterval) interval maxRetries:(int) maxRetries {
   
   int nbrTries = 0;
   for (;;) {
		
		NSArray *views = [self viewsWithQuery:query];
		
		if ([views count] > 0) {
			DC_LOG(@"View found, returning to calling method");
         return [views objectAtIndex:0];
		}
      
		// Not found exceptions trigger the continuation of the loop.
		DC_LOG(@"View not found, pausing before trying again");
		nbrTries++;
		if (nbrTries >= maxRetries) {
			// errk! We have tried too many times.
			DC_LOG(@"Retry count exceeeded!");
			@throw [SIUIException exceptionWithReason: [NSString stringWithFormat:@"Path %@ has not appeared on the UI after %i attempts", query, maxRetries]];
		}
		
		// Sleeeeeep
		[NSThread sleepForTimeInterval:interval];
	}
	
}

-(void) waitForAnimationEndOnViewWithQuery:(NSString *) query retryInterval:(NSTimeInterval) interval {
	
	UIView *view = [self waitForViewWithQuery:query retryInterval:interval maxRetries: 20];
	
	do {
		// Sleeeeeep
		[NSThread sleepForTimeInterval:interval];
		
		// Now check.
		DC_LOG(@"Checking animation keys");
		
		// Here we dig into the CALayer and get a list of all animation keys.
		// If this list is empty, then there are no more animations.
		if (![self animationsRunningOnViewHierarchy:view]) {
			DC_LOG(@"Animation appears to be over, returning");
			return;
		}
		
	} while(YES);
	
}

// If any of the views in the hierarchy have animations present then regard the passed view as still being animated.
-(BOOL) animationsRunningOnViewHierarchy:(UIView *) view {
	UIView *checkView = view;
	do {
		if ([[view.layer animationKeys] count] > 0) {
			return YES;
		}
		checkView = checkView.superview;
	} while (checkView != nil);
	return NO;
}

@end
