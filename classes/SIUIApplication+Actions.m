//
//  SIUIApplication+Actions.m
//  Simon
//
//  Created by Derek Clarkson on 4/01/13.
//  Copyright (c) 2013 Sensis. All rights reserved.
//


#import <Simon/SIUIApplication+Actions.h>
#import <NSObject+Simon.h>
#import <PublicAutomation/UIAutomationBridge.h>
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
	[self tap:view withBlock:^(BOOL delayingTouches) {
		if (delayingTouches) {
			SI_LOG_ACTION(@"Tapping a view using a long touch because of delayed touches in force");
			[UIAutomationBridge longTapView:view forDuration:0.25f];
		} else {
			SI_LOG_ACTION(@"Tapping a view");
			[UIAutomationBridge tapView:view];
		}
	}];
}

-(void) tap:(UIView *) view atPoint:(CGPoint) atPoint {
	[self tap:view withBlock:^(BOOL delayingTouches) {
		if (delayingTouches) {
			SI_LOG_ACTION(@"Tapping a view using a long touch because of delayed touches in force at point %f x %f", atPoint.x, atPoint.y);
			[UIAutomationBridge longTapView:view atPoint:atPoint forDuration:0.25f];
		} else {
			SI_LOG_ACTION(@"Tapping a view at point %f x %f", atPoint.x, atPoint.y);
			[UIAutomationBridge tapView:view atPoint:atPoint];
		}
	}];
}

#pragma mark - Swiping

-(void) swipe:(UIView *) view inDirection:(SIUISwipeDirection) swipeDirection forDistance:(int) distance {
	[self executeBlockOnMainThread:^{
		CGRect bounds = view.frame;
		CGPoint swipeStart = CGPointMake(bounds.origin.x + bounds.size.width * 0.5f, bounds.origin.y + bounds.size.height * 0.5f);
		
		int x = 1;
		int y = 1;
		switch (swipeDirection) {
			case SIUISwipeDirectionUp:
				y = -distance;
				break;
			case SIUISwipeDirectionLeft:
				x = -distance;
				break;
			case SIUISwipeDirectionRight:
				x = distance;
				break;
			default:
				y = distance;
				break;
		}
		CGPoint swipeEnd = CGPointMake(swipeStart.x + x, swipeStart.y + y);
		
		DC_LOG(@"Swiping from %.fx%.f to %.fx%.f", swipeStart.x, swipeStart.y, swipeEnd.x, swipeEnd.y);
		NSArray *dragPoints = [UIAutomationBridge swipeView:view from:swipeStart to:swipeEnd forDuration: 0.2f];
		DC_LOG(@"Swiping from %@ to %@", dragPoints[0], dragPoints[1]);
	}];
}

@end
