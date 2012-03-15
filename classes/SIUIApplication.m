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
#import "SIUIException.h"
#import "SIUIViewDescriptionVisitor.h"

#import <QuartzCore/CALayer.h>

@interface SIUIApplication(_privates)
-(SIUIViewHandler *) viewHandlerForView:(UIView *) view;
-(BOOL) animationsRunningOnViewHierarchy:(UIView *) view;
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
      self.viewHandlerFactory = [[[SIUIViewHandlerFactory alloc] init] autorelease];
   }
   return self;
}

-(void)dealloc
{
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

#pragma mark - Searching

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

-(BOOL) isViewPresent:(NSString *) query {
	return [[self findViewsWithQuery:query] count] > 0;
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
	
	NSLog(@"Tree view of current window"); 
	NSLog(@"====================================================");
	
	SIUIViewDescriptionVisitor *visitor = [[SIUIViewDescriptionVisitor alloc] initWithDelegate:self];
	[visitor visitView:[UIApplication sharedApplication].keyWindow];
	DC_DEALLOC(visitor);
}

-(void) visitedView:(UIView *) view 
		  description:(NSString *) description 
			attributes:(NSDictionary *) attributes
			 indexPath:(NSIndexPath *) indexPath
				sibling:(int) siblingIndex {
	
	// Build a string of the attributes.
	NSMutableString *attributeString = [NSMutableString string];
	[attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[attributeString appendFormat:@", @%2$@='%3$@'", key, obj];
	}];
	
	// Log the main details.
	NSString *name = NSStringFromClass([view class]);
	NSUInteger index = [indexPath indexAtPosition:[indexPath length] - 1];
	NSUInteger depth = [indexPath length];
	NSString *prefix = [@"" stringByPaddingToLength:depth * 3 withString:@"   " startingAtIndex:0];
	NSString *siblingString = siblingIndex > 0 ? [NSString stringWithFormat:@" [%i]", siblingIndex]: @"";
	NSLog(@"%1$@[%3$i] %2$@%4$@%5$@", prefix, name, index, siblingString, attributeString);
	
}


#pragma mark - Tapping

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

#pragma mark - Swiping

-(void) swipeViewWithQuery:(NSString *) query inDirection:(SIUISwipeDirection) swipeDirection forDistance:(int) distance {
   UIView<DNNode> *theView = [[SIUIApplication application] findViewWithQuery:query];
   [[self viewHandlerForView:theView] swipe:swipeDirection distance:distance]; 
}

#pragma mark - View handlers

-(SIUIViewHandler *) viewHandlerForView:(UIView *) view {
   SIUIViewHandler *handler = [self.viewHandlerFactory handlerForView:view];
   handler.view = view;
   return handler;
}

#pragma mark - Pauses and holds

-(void) pauseFor:(NSTimeInterval) duration {
   [NSThread sleepForTimeInterval:duration];
}

-(UIView *) waitForViewWithQuery:(NSString *) query retryInterval:(NSTimeInterval) interval maxRetries:(int) maxRetries {
   
   int nbrTries = 0;
   for (;;) {
      @try {
         // Attempt to return the UIView found.
         UIView *view = [self findViewWithQuery:query];
         DC_LOG(@"View found, returning to calling method");
         return view;
      }
      @catch (SIUINotFoundException *notFoundException) {
         
         // Not found exceptions trigger the continuation of the loop.
         DC_LOG(@"View not found, pausing before trying again");
         nbrTries++;
         if (nbrTries >= maxRetries) {
            // errk! Less we have tried too many times.
            DC_LOG(@"Retry count exceeeded!");
            @throw [SIUIException exceptionWithReason: [NSString stringWithFormat:@"Path %@ has not appeared on the UI after %i attempts", query, maxRetries]];
         }
         
         // Sleeeeeep
         [NSThread sleepForTimeInterval:interval];
      }
      
   };
	
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
