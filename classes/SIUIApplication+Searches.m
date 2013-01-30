//
//  SIUIApplication+Searches.m
//  Simon
//
//  Created by Derek Clarkson on 4/01/13.
//  Copyright (c) 2013 Sensis. All rights reserved.
//

#import <Simon/SIUIApplication+Searches.h>
#import <Simon/SIUINotFoundException.h>
#import <Simon/SISyntaxException.h>
#import <Simon/SIUITooManyFoundException.h>
#import <Simon/NSObject+Simon.h>
#import <dUsefulStuff/DCCommon.h>
#import <dNodi/DNExecutor.h>
#import <Simon/UIView+Simon.h>

@interface SIUIApplication(_internalSearches)
-(NSArray *) findViewsOnKeyWindowWithQuery:(NSString *) query;
-(NSArray *) findViewsOnAllWindowsWithQuery:(NSString *) query;
-(NSArray *) findViewsOnWindow:(UIWindow *) window withQuery:(NSString *) query;
@end

@implementation SIUIApplication (Searches)

#pragma mark - Core calls

-(NSArray *) viewsWithQuery:(NSString *) query {
	
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

-(UIView *) viewWithQuery:(NSString *) query {
	return [self viewWithQuery:query timeout:self.timeout];
}

-(UIView *) viewWithQuery:(NSString *) query timeout:(NSTimeInterval) timeout {
	
	if (self.logActions) {
		NSLog(@"Finding single view with %@ within %.f seconds", query, timeout);
	}
	
	// Calculate the timeout target.
	NSDate *expires = [NSDate dateWithTimeIntervalSinceNow:timeout];
	
	do {
		NSArray *views = [self viewsWithQuery:query];
		if ([views count] == 1) {
			// Found it.
			return views[0];
		}
		if ([views count] > 1) {
			// Opps - too many.
			@throw [SIUITooManyFoundException exceptionWithReason: [NSString stringWithFormat:@"Path %@ should return one view only, got %u instead.", query, [views count]]];
		}
		
		// Sleep.
		[NSThread sleepForTimeInterval:self.retryFrequency];
		
	} while ([(NSDate *)[NSDate date] compare:expires] != NSOrderedDescending);
	
	// Not found so throw.
	@throw [SIUINotFoundException exceptionWithReason: [NSString stringWithFormat:@"Path %@ failed to find anything.", query]];
	
}

#pragma mark - Extensions

-(UIView *) viewWithTag:(NSInteger) tag {
	return [self viewWithTag:tag timeout:self.timeout];
}

-(UIView *) viewWithTag:(NSInteger) tag timeout:(NSTimeInterval) timeout {
	return [self viewWithQuery:[NSString stringWithFormat:@"//[tag='%i']", tag] timeout:timeout];
}

-(BOOL) isViewPresent:(NSString *) query {
	UIView *view = nil;
	return [self isViewPresent:query view:&view];
}

-(BOOL) isViewPresent:(NSString *) query view:(UIView **)view {
	NSArray *views = [self viewsWithQuery:query];
	BOOL present = [views count] > 0;
	if (self.logActions) {
		NSLog(@"Checking if view %@ is present: %@", query, DC_PRETTY_BOOL(present));
	}
	if (present) {
		*view = views[0];
	}
	return present;
}

-(UIButton *) buttonWithLabel:(NSString *) label {
	return [self buttonWithLabel:label timeout:self.timeout];
}

-(UIButton *) buttonWithLabel:(NSString *) label timeout:(NSTimeInterval) timeout {
	return (UIButton *)[self viewWithQuery:[NSString stringWithFormat:@"//UI*Button/UI*ButtonLabel[text='%@']/..", label] timeout:timeout];
}

-(UIView *) tabBarButtonWithLabel:(NSString *) label {
	return [self tabBarButtonWithLabel:label timeout:self.timeout];
}

-(UIView *) tabBarButtonWithLabel:(NSString *) label timeout:(NSTimeInterval) timeout {
	return [self viewWithQuery:[NSString stringWithFormat:@"//UI*Button/UITabBarButtonLabel[text='%@']/..", label] timeout:timeout];
}


#pragma mark - Internal helpers

-(NSArray *) findViewsOnKeyWindowWithQuery:(NSString *) query {
	UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
   return [self findViewsOnWindow:keyWindow withQuery:query];
}

-(NSArray *) findViewsOnAllWindowsWithQuery:(NSString *) query {
	
	if (self.logActions) {
		NSLog(@"Finding views on all windows with %@", query);
	}
	
	NSMutableArray *results = [NSMutableArray array];
	for (UIWindow *window in [UIApplication sharedApplication].windows) {
		[results addObjectsFromArray:[self findViewsOnWindow:window withQuery:query]];
	}
	return results;
	
}

-(NSArray *) findViewsOnWindow:(UIWindow *) window withQuery:(NSString *) query {
	if (self.logActions) {
		SI_LOG_ACTION(@"Searching UIWindow for views with %@", query);
	}
	
	// Create an executor and search the tree.
	DNExecutor *executor = [[DNExecutor alloc] initWithRootNode: window];
   NSError *error = nil;
	NSArray *results = [executor executeQuery: query error:&error];
	[executor release];
   
   if (results == nil) {
      @throw [SISyntaxException exceptionWithReason: [error localizedFailureReason]];
   }
	
   return results;
	
}

@end
