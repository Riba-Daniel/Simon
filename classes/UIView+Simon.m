//
//  UIView+Simon.m
//  Simon
//
//  Created by Derek Clarkson on 7/23/11.
//  Copyright 2011. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>

#import "UIView+Simon.h"
#import "TouchSynthesis.h"
#import "SIUIHandlerFactory.h"

@interface UIView (_private)
@end

@implementation UIView (Simon)

-(NSString *)name {
	return [[SIUIHandlerFactory handlerFactory] createHandlerForView:self].name;
}

-(NSObject<DNNode> *)parentNode {
	return [[SIUIHandlerFactory handlerFactory] createHandlerForView:self].parentNode;
}

-(NSArray *)subNodes {
	return [[SIUIHandlerFactory handlerFactory] createHandlerForView:self].subNodes;
}

-(NSObject *) objectForAttribute:(NSString *) attribute {
	return [[[SIUIHandlerFactory handlerFactory] createHandlerForView:self] objectForAttribute:attribute];
}

@end
