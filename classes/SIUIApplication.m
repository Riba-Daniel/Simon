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

#import "UIView+Simon.h"
#import <Simon/SIConstants.h>
#import <Simon/SISyntaxException.h>
#import "SIUITooManyFoundException.m"
#import <Simon/SIUINotFoundException.h>
#import <Simon/SIUIViewHandler.h>
#import <Simon/SIUIViewHandlerFactory.h>
#import <Simon/SIUIException.h>
#import <Simon/SIUIViewDescriptionVisitor.h>
#import "NSObject+Simon.h"
#import <Simon/SIUINotAnInputViewException.h>
#import <Simon/SIAppBackpack.h>
#import <Simon/SIUIApplication.h>

#import <QuartzCore/CALayer.h>

@interface SIUIApplication(_privates)
-(SIUIViewHandler *) viewHandlerForView:(UIView *) view;
-(BOOL) animationsRunningOnViewHierarchy:(UIView *) view;
-(NSArray *) findViewsOnKeyWindowWithQuery:(NSString *) query;
-(NSArray *) findViewsOnAllWindowsWithQuery:(NSString *) query;
@end

@implementation SIUIApplication

static SIUIApplication *application = nil;

@synthesize viewHandlerFactory = viewHandlerFactory_;
@synthesize disableKeyboardAutocorrect = disableAutoCorrect_;
@synthesize logActions = logActions_;

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
		SIUIViewHandlerFactory *factory = [[SIUIViewHandlerFactory alloc] init];
      self.viewHandlerFactory = factory;
		self.logActions = [SIAppBackpack isArgumentPresentWithName:ARG_LOG_ACTIONS];
		[factory release];
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
	
	if (self.logActions) {
		NSLog(@"Finding views with %@", query);
	}

	__block NSArray *views;
	__block NSException *exception = nil;
	
	[self executeBlockOnMainThread: ^{
		@try {
			views = [self findViewsOnKeyWindowWithQuery:query];
			// Retain so data survives GCDs autorelease pools.
			[views retain];
			DC_LOG(@"Returning %u views to background thread", [views count]);
		}
		@catch (NSException *e) {
			// Retain the exception.
			exception = [e retain];
		}
	}];
	
	if (exception != nil) {
		@throw [exception autorelease];
	}
	
	// Now autorelease and return.
	return [views autorelease];
	
}

-(NSArray *) findViewsOnKeyWindowWithQuery:(NSString *) query {
	
	if (self.logActions) {
		NSLog(@"Finding views on key window with %@", query);
	}

	// Get the window as the root node.
	DC_LOG(@"Searching for views based on the query \"%@\"", query);
	UIView *keyWindow = [UIApplication sharedApplication].keyWindow;
	
	// Create an executor and search the tree.
	DNExecutor *executor = [[DNExecutor alloc] initWithRootNode: keyWindow];
   NSError *error = nil;
	NSArray *results = [executor executeQuery: query error:&error];
	[executor release];
   
   if (results == nil) {
      @throw [SISyntaxException exceptionWithReason: [error localizedFailureReason]]; 
   }
	
   return results;
}

-(NSArray *) findViewsOnAllWindowsWithQuery:(NSString *) query {

	if (self.logActions) {
		NSLog(@"Finding views on all windows with %@", query);
	}

	NSMutableArray *results = [NSMutableArray array];
	NSArray *windowResults = nil;
	
	for (UIWindow *window in [UIApplication sharedApplication].windows) {
		// Create an executor and search the tree.
		DNExecutor *executor = [[DNExecutor alloc] initWithRootNode: window];
		NSError *error = nil;
		windowResults = [executor executeQuery: query error:&error];
		[executor release];
		if (windowResults == nil) {
			@throw [SISyntaxException exceptionWithReason: [error localizedFailureReason]]; 
		}
		[results addObjectsFromArray:windowResults];
	}
	return results;
	
}

-(UIView *) findViewWithQuery:(NSString *) query {
	
	if (self.logActions) {
		NSLog(@"Finding single view with %@", query);
	}

	NSArray *views = [self findViewsWithQuery:query];
	
	// Validate that we only have a single view.
	if ([views count] == 0) {
      @throw [SIUINotFoundException exceptionWithReason: [NSString stringWithFormat:@"Path %@ failed to find anything.", query]];
	}
	if ([views count] > 1) {
      @throw [SIUITooManyFoundException exceptionWithReason: [NSString stringWithFormat:@"Path %@ should return one view only, got %u instead.", query, [views count]]];
	}
	
	UIView *view = [views objectAtIndex:0];
	DC_LOG(@"Found view %@", view);
	return view;
}

-(BOOL) isViewPresent:(NSString *) query {
	BOOL present = [[self findViewsWithQuery:query] count] > 0;
	if (self.logActions) {
		NSLog(@"Checking if view %@ is present: %@", query, DC_PRETTY_BOOL(present));
	}
	return present;
}

-(void) logUITree {
	
	[self executeBlockOnMainThread:^{
		
		NSLog(@"Tree view of current window"); 
		NSLog(@"====================================================");
		
		SIUIViewDescriptionVisitor *visitor = [[SIUIViewDescriptionVisitor alloc] initWithDelegate:self];
		[visitor visitAllWindows];
		//[visitor visitView:[UIApplication sharedApplication].keyWindow];
		DC_DEALLOC(visitor);
	}];
	
}

-(void) visitedView:(UIView *) view 
		  description:(NSString *) description 
			attributes:(NSDictionary *) attributes
			 indexPath:(NSIndexPath *) indexPath
				sibling:(int) siblingIndex {
	
	// Build a string of the attributes.
	NSMutableString *attributeString = [NSMutableString string];
	[attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[attributeString appendFormat:@", @%@='%@'", key, obj];
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

-(UIView *) tapView:(UIView *) view {
	if (self.logActions) {
		NSLog(@"Tapping a view");
	}
   [[self viewHandlerForView:view] tap];
	return view;
}

-(UIView *) tapView:(UIView *) view atPoint:(CGPoint) atPoint {
	if (self.logActions) {
		NSLog(@"Tapping a view at point %f x %f", atPoint.x, atPoint.y);
	}
   [[self viewHandlerForView:view] tapAtPoint:atPoint];
	return view;
}

-(UIView *) tapViewWithQuery:(NSString *) query {
	if (self.logActions) {
		NSLog(@"Tapping view %@", query);
	}
   UIView<DNNode> *theView = [self findViewWithQuery:query];
   return [self tapView:theView];
}

-(UIView *) tapViewWithQuery:(NSString *) query atPoint:(CGPoint) atPoint {
	if (self.logActions) {
		NSLog(@"Tapping view %@ at point %f x %f", query, atPoint.x, atPoint.y);
	}
   UIView<DNNode> *theView = [self findViewWithQuery:query];
   return [self tapView:theView atPoint:atPoint];
}

-(void) tapButtonWithLabel:(NSString *) label {
   @try {
      [self tapViewWithQuery:[NSString stringWithFormat:@"//UIRoundedRectButton[@titleLabel.text='%@']", label]];
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
   [self tapViewWithQuery:[NSString stringWithFormat:@"//UITabBarButtonLabel[@text='%@']/..", label]];
}

#pragma mark - Swiping

-(UIView *) swipeView:(UIView *) view inDirection:(SIUISwipeDirection) swipeDirection forDistance:(int) distance {
   [[self viewHandlerForView:view] swipe:swipeDirection distance:distance]; 
	return view;
}

-(UIView *) swipeViewWithQuery:(NSString *) query inDirection:(SIUISwipeDirection) swipeDirection forDistance:(int) distance {
   UIView<DNNode> *theView = [self findViewWithQuery:query];
   return [self swipeView:theView inDirection:swipeDirection forDistance:distance];
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

#pragma mark - Text handling

-(void) enterText:(NSString *) text intoView:(UIView *) view {
	
	if (![view conformsToProtocol:@protocol(UITextInput)]) {
		@throw [SIUINotAnInputViewException exceptionWithReason: [NSString stringWithFormat:@"%@ is not an input field.", NSStringFromClass([view class])]];
	}
	
	// If the view does not have focus then make sure it does.
	if (![view isFirstResponder]) {
		[self tapView:view];
	}
	
	// Enter the text.
	[[self viewHandlerForView:view] enterText:text keyRate:0.1 autoCorrect: ! self.disableKeyboardAutocorrect];
	
}

-(void) enterText:(NSString *) text intoViewWithQuery:(NSString *) query {
	UIView<DNNode> *theView = [self findViewWithQuery:query];
	[self enterText:text intoView:theView];
}

@end
