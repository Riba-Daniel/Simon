//
//  SIUIViewHandler.m
//  Simon
//
//  Created by Derek Clarkson on 13/09/11.
//  Copyright (c) 2011. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import "SIUIViewHandler.h"

@implementation SIUIViewHandler

@synthesize view = view_;
@synthesize eventCannon = eventCannon_;

-(void) dealloc {
   self.view = nil;
   self.eventCannon = nil;
   [super dealloc];
}

#pragma mark - DNNode

-(NSString *)name {
	return NSStringFromClass([self.view class]);
}

-(NSObject<DNNode> *)parentNode {
	return (NSObject<DNNode> *) self.view.superview;
}

-(NSArray *)subNodes {
	// Return a copy as this has been known to change whilst this code is executing.
	return [[self.view.subviews copy] autorelease];	
}

-(BOOL) hasAttribute:(NSString *)attribute withValue:(id)value {
	// Use KVC to test the value.
	id propertyValue = [self.view valueForKeyPath:attribute];
	return [propertyValue isEqual:value];
}

#pragma mark - SIUIAction

-(void) tap {
   [self.eventCannon tapView:self.view];
}

-(void) swipe:(SIUISwipeDirection) swipeDirection distance:(int) distance {
   [self.eventCannon swipeView:self.view direction:swipeDirection distance:distance];
}

@end
