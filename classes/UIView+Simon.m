//
//  UIView+Simon.m
//  Simon
//
//  Created by Derek Clarkson on 7/23/11.
//  Copyright 2011 Sensis. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>

#import "UIView+Simon.h"
#import "TouchSynthesis.h"

@implementation UIView (Simon)


// Simon's node methods.

-(NSString *)name {
	return NSStringFromClass([self class]);
}

-(NSObject<DNNode> *)parentNode {
	return self.superview;
}

-(NSArray *)subNodes {
	// Return a copy as this has been known to change whilst this code is executing.
	return [self.subviews copy];	
}

-(NSObject *) objectForAttribute:(NSString *) attribute {
	return nil;
}

@end
