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

@interface UIView (_private)
@end

@implementation UIView (Simon)

-(NSString *)name {
	return [[SIUIViewHandlerFactory handlerFactory] createHandlerForView:self].name;
}

-(NSObject<DNNode> *)parentNode {
	return [[SIUIViewHandlerFactory handlerFactory] createHandlerForView:self].parentNode;
}

-(NSArray *)subNodes {
	return [[SIUIViewHandlerFactory handlerFactory] createHandlerForView:self].subNodes;
}

-(BOOL) hasAttribute:(NSString *)attribute withValue:(id)value {
	return [[[SIUIViewHandlerFactory handlerFactory] createHandlerForView:self] hasAttribute:attribute withValue:value];
}

@end
