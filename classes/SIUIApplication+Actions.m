//
//  SIUIApplication+Actions.m
//  Simon
//
//  Created by Derek Clarkson on 4/01/13.
//  Copyright (c) 2013 Sensis. All rights reserved.
//


#import <Simon/SIUIApplication+Actions.h>
#import <NSObject+Simon.h>
#import <Simon/SIUIApplication+Searches.h>

@class UIAutomation;

@interface SIUIApplication (_internal)
-(void) tap:(UIView *)view withBlock:(void (^)(BOOL delayedTouches)) tapBlock;
@end

@implementation SIUIApplication (_internal)
-(void) tap:(UIView *)view withBlock:(void (^)(BOOL delayedTouches)) tapBlock {
	[self executeBlockOnMainThread:^{
		
		// Find out of we are dealing with a UIScrollView.
		UIView *parent = view;
		BOOL delayingTouches = NO;
		do {
			if ([parent isKindOfClass:[UIScrollView class]]) {
				DC_LOG(@"Found UIScrollView.delaysContentTouches: %@", DC_PRETTY_BOOL(((UIScrollView *)parent).delaysContentTouches));
				delayingTouches = ((UIScrollView *)parent).delaysContentTouches;
				break;
			}
			parent = parent.superview;
		} while (parent != nil);
		
		tapBlock(delayingTouches);
	}];
	
}

@end

@implementation SIUIApplication (Actions)

#pragma mark - Tapping

-(void) tap:(UIView *) view {
	if (self.logActions) {
		NSLog(@"Tapping a view");
	}
   [[self viewHandlerForView:view] tap];
}

-(void) tap:(UIView *) view atPoint:(CGPoint) atPoint {
	if (self.logActions) {
		NSLog(@"Tapping a view at point %f x %f", atPoint.x, atPoint.y);
	}
   [[self viewHandlerForView:view] tapAtPoint:atPoint];
}

#pragma mark - Swiping

-(void) swipe:(UIView *) view inDirection:(SIUISwipeDirection) swipeDirection forDistance:(int) distance {
   [[self viewHandlerForView:view] swipe:swipeDirection distance:distance];
}

@end
