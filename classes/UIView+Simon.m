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

-(void) swipe:(SIUISwipeDirection) swipeDirection distance:(int) distance {
   [[[SIUIApplication application].viewHandlerFactory handlerForView:self] swipe:swipeDirection distance:distance];
}

-(NSDictionary *) kvcAttributes {
   return [[[SIUIApplication application].viewHandlerFactory handlerForView:self] kvcAttributes];
}

@end
