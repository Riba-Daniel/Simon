//
//  UIView+Simon.m
//  Simon
//
//  Created by Derek Clarkson on 7/23/11.
//  Copyright 2011. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import "UIView+Simon.h"
#import "UITouch+Simon.h"
#import "UIEvent+Simon.h"
#import <Simon/SIUIViewHandlerFactory.h>
#import <Simon/SIUIApplication.h>

// We need to clear the view after each call so that the handler does not hang onto a view which is no longer valid. Leaving
// the view retained will trigger zombies. Still not sure exactly why, but it's something to do with the view no longer being 
// present. Still should clear here anyway.

@implementation UIView (Simon)

#pragma mark - Querying

-(NSString *)dnName {
	return [[SIUIApplication application].viewHandlerFactory handlerForView:self].dnName;
}

-(NSObject<DNNode> *)dnParentNode {
	return [[SIUIApplication application].viewHandlerFactory handlerForView:self].dnParentNode;
}

-(NSArray *)dnSubNodes {
	return [[SIUIApplication application].viewHandlerFactory handlerForView:self].dnSubNodes;
}

-(BOOL) dnHasAttribute:(NSString *)attribute withValue:(id)value {
	return [[[SIUIApplication application].viewHandlerFactory handlerForView:self] dnHasAttribute:attribute withValue:value];
}

#pragma mark - Actions

-(void) tap {
	[[[SIUIApplication application].viewHandlerFactory handlerForView:self] tap];
}

-(void) tapAtPoint:(CGPoint) atPoint {
	[[[SIUIApplication application].viewHandlerFactory handlerForView:self] tapAtPoint:atPoint];
}

-(void) swipe:(SIUISwipeDirection) swipeDirection distance:(int) distance {
   [[[SIUIApplication application].viewHandlerFactory handlerForView:self] swipe:swipeDirection distance:distance];
}

-(NSDictionary *) kvcAttributes {
   return [[[SIUIApplication application].viewHandlerFactory handlerForView:self] kvcAttributes];
}

-(void) enterText:(NSString *) text keyRate:(NSTimeInterval) keyRate autoCorrect:(BOOL)autoCorrect {
	[[[SIUIApplication application].viewHandlerFactory handlerForView:self] enterText:text keyRate:keyRate autoCorrect:autoCorrect];
}

-(CGPoint) pointInWindowFromPointInView:(CGPoint) pointInView {
	return [self convertPoint:pointInView toView:nil];
}

@end
