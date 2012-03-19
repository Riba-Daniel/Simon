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
#import "SIUIViewHandlerFactory.h"

// We need to clear the view after each call so that the handler does not hang onto a view which is no longer valid. Leaving
// the view retained will trigger zombies. Still not sure exactly why, but it's something to do with the view no longer being 
// present. Still should clear here anyway.

@implementation UIView (Simon)

#pragma mark - Querying

-(NSString *)dnName {
	SIUIViewHandler *handler = [[SIUIApplication application].viewHandlerFactory handlerForView:self];
	NSString * name = handler.dnName;
	handler.view = nil;
	return name;
}

-(NSObject<DNNode> *)dnParentNode {
	SIUIViewHandler *handler = [[SIUIApplication application].viewHandlerFactory handlerForView:self];
	NSObject<DNNode> * parent = handler.dnParentNode;
	handler.view = nil;
	return parent;
}

-(NSArray *)dnSubNodes {
	SIUIViewHandler *handler = [[SIUIApplication application].viewHandlerFactory handlerForView:self];
	NSArray * subnodes = handler.dnSubNodes;
	handler.view = nil;
	return subnodes;
}

-(BOOL) dnHasAttribute:(NSString *)attribute withValue:(id)value {
	SIUIViewHandler *handler = [[SIUIApplication application].viewHandlerFactory handlerForView:self];
	BOOL hasAttribute = [handler dnHasAttribute:attribute withValue:value];
	handler.view = nil;
	return hasAttribute;
}

#pragma mark - Actions

-(void) tap {
	SIUIViewHandler *handler = [[SIUIApplication application].viewHandlerFactory handlerForView:self];
	[handler tap];
	handler.view = nil;
}

-(void) tapAtPoint:(CGPoint) atPoint {
	SIUIViewHandler *handler = [[SIUIApplication application].viewHandlerFactory handlerForView:self];
	[handler tapAtPoint:atPoint];
	handler.view = nil;
}

-(void) swipe:(SIUISwipeDirection) swipeDirection distance:(int) distance {
	SIUIViewHandler *handler = [[SIUIApplication application].viewHandlerFactory handlerForView:self];
	[handler swipe:swipeDirection distance:distance];
	handler.view = nil;
}

-(NSDictionary *) kvcAttributes {
	SIUIViewHandler *handler = [[SIUIApplication application].viewHandlerFactory handlerForView:self];
	NSDictionary * attribute = [handler kvcAttributes];
	handler.view = nil;
	return attribute;
}

-(CGPoint) pointInWindowFromPointInView:(CGPoint) pointInView {
	return [self convertPoint:pointInView toView:nil];
}

@end
