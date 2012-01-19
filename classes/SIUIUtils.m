//
//  SIUIUtils.m
//  Simon
//
//  Created by Derek Clarkson on 7/23/11.
//  Copyright 2011. All rights reserved.
//
#import <dNodi/DNExecutor.h>
#import <UIKit/UIKit.h>
#import <dUsefulStuff/DCCommon.h>
#import <dUsefulStuff/NSObject+dUsefulStuff.h>

#import "SIUIUtils.h"
#import "UIView+Simon.h"
#import "SIConstants.h"

@interface SIUIUtils()
+(void) logSubviewsOfView:(UIView *) view widthPrefix:(NSString *) prefix index:(int) index;
@end

@implementation SIUIUtils

+(NSArray *) findViewsWithQuery:(NSString *) query error:(NSError **) error {
	
	SI_LOG(@"On main thread: %@", DC_PRETTY_BOOL([[NSThread currentThread] isMainThread]));
	
	// Redirect to the main thread.
	if (![[NSThread currentThread] isMainThread]) {
		
		SI_LOG(@"Redirecting to main thread via GCD");
		dispatch_queue_t mainQueue = dispatch_get_main_queue();
		
		__block NSArray *views;
      
		dispatch_sync(mainQueue, ^{
			views = [SIUIUtils findViewsWithQuery:query error:error];
			// Retain so data survives GCDs autorelease pools.
			[*error retain];
			[views retain];
			SI_LOG(@"Returning %lu views to background thread", [views count]);
		});
		
		// Now autorelease and return.
		[*error autorelease];
		return [views autorelease];
	}
	
	SI_LOG(@"Searching for views based on the query \"%@\"", query);
	
	// Get the window as the root node.
	UIView *keyWindow = [UIApplication sharedApplication].keyWindow;
	
	// Create an executor and search the tree.
	DNExecutor *executor = [[[DNExecutor alloc] initWithRootNode: keyWindow] autorelease];
	return [executor executeQuery: query error:error];
	
}

+(UIView *) findViewWithQuery:(NSString *) query error:(NSError **) error {
	
	NSArray *views = [self findViewsWithQuery:query error:error];
	if (views == nil) {
		return nil;
	}
	
	// Validate that we only have a single view.
	if ([views count] != 1) {
		[self setError:error 
					 code:SIUIErrorExpectOnlyOneView
			errorDomain:SIMON_ERROR_DOMAIN
	 shortDescription:@"Expected only one view" 
		 failureReason:[NSString stringWithFormat:@"Expected only one view, got %lu instead.", [views count]]];
		return nil;
	}
	
	return (UIView *) [views objectAtIndex:0];
}

+(void) logUITree {
	
	SI_LOG(@"On main thread: %@", DC_PRETTY_BOOL([[NSThread currentThread] isMainThread]));
	
	// Redirect to the main thread.
	if (![[NSThread currentThread] isMainThread]) {
		SI_LOG(@"Redirecting to main thread via GCD");
		dispatch_queue_t mainQueue = dispatch_get_main_queue();
		dispatch_sync(mainQueue, ^{
			[self logUITree];
		});
		return;
	}
	
	UIWindow * window = [UIApplication sharedApplication].keyWindow;
	NSLog(@"Tree view of current window");
	NSLog(@"====================================================");
	[self logSubviewsOfView:window widthPrefix:@"" index:0];
}

+(void) logSubviewsOfView:(UIView *) view widthPrefix:(NSString *) prefix index:(int) index {
	
	// Find out if we have some text.
	NSString *name;
	if ([view respondsToSelector:@selector(text)]) {
		name = [NSString stringWithFormat:@"%@ \"%@\"", NSStringFromClass([view class]), [view performSelector:@selector(text)]];
	} else {
		name = NSStringFromClass([view class]);
	}
	
	NSLog(@"%@[%i] %@", prefix, index, name);
	
	// Now recursively handle sub views.
	NSString * offset = [NSString stringWithFormat:@"%@%@", prefix, @"   "];
	
	int subViewIndex = 0;
	for (UIView * subview in view.subviews) {
		[self logSubviewsOfView:subview widthPrefix:offset index:subViewIndex++];
	}
}

@end
