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
#import "SISyntaxException.h"
#import "SIUITooManyFoundException.m"
#import "SIUINotFoundException.h"

@interface SIUIUtils()
+(void) logSubviewsOfView:(UIView *) view widthPrefix:(NSString *) prefix index:(int) index;
@end

@implementation SIUIUtils

+(NSArray *) findViewsWithQuery:(NSString *) query {
	
	DC_LOG(@"On main thread: %@", DC_PRETTY_BOOL([[NSThread currentThread] isMainThread]));
	
	// Redirect to the main thread.
	if (![[NSThread currentThread] isMainThread]) {
		
		DC_LOG(@"Redirecting to main thread via GCD");
		dispatch_queue_t mainQueue = dispatch_get_main_queue();
		
		__block NSArray *views;
      __block NSException *exception = nil;
      
		dispatch_sync(mainQueue, ^{
         @try {
            views = [SIUIUtils findViewsWithQuery:query];
            // Retain so data survives GCDs autorelease pools.
            [views retain];
            DC_LOG(@"Returning %lu views to background thread", [views count]);
         }
         @catch (NSException *e) {
            // Retain the exception.
            exception = [e retain];
         }
		});

		if (exception != nil) {
         @throw [exception autorelease];
      }
      
		// Now autorelease and return.
		return [views autorelease];
	}
	
	// Get the window as the root node.
	DC_LOG(@"Searching for views based on the query \"%@\"", query);
	UIView *keyWindow = [UIApplication sharedApplication].keyWindow;
	
	// Create an executor and search the tree.
	DNExecutor *executor = [[[DNExecutor alloc] initWithRootNode: keyWindow] autorelease];
   NSError *error = nil;
	NSArray *results = [executor executeQuery: query error:&error];
   
   if (results == nil) {
      @throw [SISyntaxException exceptionWithReason: [error localizedFailureReason]]; 
   }
   
   return results;
	
}

+(UIView *) findViewWithQuery:(NSString *) query {
	
	NSArray *views = [self findViewsWithQuery:query];
	
	// Validate that we only have a single view.
	if ([views count] == 0) {
      @throw [SIUINotFoundException exceptionWithReason: [NSString stringWithFormat:@"Path %@ failed to find anything.", query]];
	}
	if ([views count] > 1) {
      @throw [SIUITooManyFoundException exceptionWithReason: [NSString stringWithFormat:@"Path %@ should return one view only, got %lu instead.", query, [views count]]];
	}
	
	return (UIView *) [views objectAtIndex:0];
}

+(void) logUITree {
	
	DC_LOG(@"On main thread: %@", DC_PRETTY_BOOL([[NSThread currentThread] isMainThread]));
	
	// Redirect to the main thread.
	if (![[NSThread currentThread] isMainThread]) {
		DC_LOG(@"Redirecting to main thread via GCD");
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

+(BOOL) tapViewWithQuery:(NSString *) query {

   UIView<DNNode> *theView = [SIUIUtils findViewWithQuery:query];
   
   DC_LOG(@"About to tap %@", theView); 
   SIUIViewHandler *handler = [[SIUIHandlerFactory handlerFactory] createHandlerForView: theView]; 
   [handler tap]; 
   return YES;
}

+(void) tapButtonWithLabel:(NSString *) label {
   @try {
      [SIUIUtils tapViewWithQuery:[NSString stringWithFormat:@"//UIRoundedRectButton[@titleLabel.text='%@']", label]];
   }
   @catch (SIUINotFoundException *exception) {
      @throw [SIUINotFoundException exceptionWithReason:[NSString stringWithFormat:@"%@ not found.", label]];
   }
}

+(void) tapButtonWithLabel:(NSString *) label andWait:(NSTimeInterval) seconds {
   [self tapButtonWithLabel:label];
   [NSThread sleepForTimeInterval:seconds];
}


+(void) tapTabBarButtonWithLabel:(NSString *) label {
   [SIUIUtils tapViewWithQuery:[NSString stringWithFormat:@"//UITabBarButtonLabel[@text='%@']/..", label]];
}



@end
