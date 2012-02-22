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

#import "SIUIApplication.h"
#import "UIView+Simon.h"
#import "SIConstants.h"
#import "SISyntaxException.h"
#import "SIUITooManyFoundException.m"
#import "SIUINotFoundException.h"
#import "SIUIViewHandler.h"
#import "SIUIViewHandlerFactory.h"

@interface SIUIApplication(_privates)
-(void) logSubviewsOfView:(UIView *) view widthPrefix:(NSString *) prefix index:(int) index;
-(SIUIViewHandler *) viewHandlerForView:(UIView *) view;
@end

@implementation SIUIApplication

static SIUIApplication *application = nil;

@synthesize viewHandlerFactory = viewHandlerFactory_;

#pragma mark - Accessors

+ (SIUIApplication *)application {
   if (application == nil) {
      application = [[super allocWithZone:NULL] init];
   }
   return application;
}

#pragma mark - Singleton overrides

- (id)init
{
   self = [super init];
   if (self) {
      eventCannon = [[SIUIEventCannon alloc] init];
      self.viewHandlerFactory = [[[SIUIViewHandlerFactory alloc] init] autorelease];
   }
   return self;
}

-(void)dealloc
{
   DC_DEALLOC(eventCannon);
   self.viewHandlerFactory = nil;
   [super dealloc];
}

+ (id)allocWithZone:(NSZone*)zone {
   return [[self application] retain];
}

- (id)copyWithZone:(NSZone *)zone {
   return self;
}

- (id)retain {
   return self;
}

- (NSUInteger)retainCount {
   return NSUIntegerMax;
}

- (oneway void)release {
}

- (id)autorelease {
   return self;
}

#pragma mark Searching

-(NSArray *) findViewsWithQuery:(NSString *) query {
	
	DC_LOG(@"On main thread: %@", DC_PRETTY_BOOL([[NSThread currentThread] isMainThread]));
	
	// Redirect to the main thread.
	if (![[NSThread currentThread] isMainThread]) {
		
		DC_LOG(@"Redirecting to main thread via GCD");
		dispatch_queue_t mainQueue = dispatch_get_main_queue();
		
		__block NSArray *views;
      __block NSException *exception = nil;
      
		dispatch_sync(mainQueue, ^{
         @try {
            views = [[SIUIApplication application] findViewsWithQuery:query];
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

-(UIView *) findViewWithQuery:(NSString *) query {
	
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

-(void) logUITree {
	
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

-(void) logSubviewsOfView:(UIView *) view widthPrefix:(NSString *) prefix index:(int) index {
	
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

-(void) tapViewWithQuery:(NSString *) query {
   UIView<DNNode> *theView = [[SIUIApplication application] findViewWithQuery:query];
   [[self viewHandlerForView:theView] tap];
}

-(void) tapButtonWithLabel:(NSString *) label {
   @try {
      [[SIUIApplication application] tapViewWithQuery:[NSString stringWithFormat:@"//UIRoundedRectButton[@titleLabel.text='%@']", label]];
   }
   @catch (SIUINotFoundException *exception) {
      @throw [SIUINotFoundException exceptionWithReason:[NSString stringWithFormat:@"%@ not found.", label]];
   }
}

-(void) tapButtonWithLabel:(NSString *) label andWait:(NSTimeInterval) seconds {
   [self tapButtonWithLabel:label];
   [NSThread sleepForTimeInterval:seconds];
}

-(void) tapTabBarButtonWithLabel:(NSString *) label {
   [[SIUIApplication application] tapViewWithQuery:[NSString stringWithFormat:@"//UITabBarButtonLabel[@text='%@']/..", label]];
}

-(void) swipeViewWithQuery:(NSString *) query inDirection:(SIUISwipeDirection) swipeDirection forDistance:(int) distance {
   UIView<DNNode> *theView = [[SIUIApplication application] findViewWithQuery:query];
   [[self viewHandlerForView:theView] swipe:swipeDirection distance:distance]; 
}

-(SIUIViewHandler *) viewHandlerForView:(UIView *) view {
   SIUIViewHandler *handler = [self.viewHandlerFactory handlerForView:view];
   handler.view = view;
   return handler;
}



@end
