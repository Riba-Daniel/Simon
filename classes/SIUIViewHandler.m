//
//  SIUIViewHandler.m
//  Simon
//
//  Created by Derek Clarkson on 13/09/11.
//  Copyright (c) 2011. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import "SIUIViewHandler.h"
#import "SIUITapGenerator.h"
#import "SIUISwipeGenerator.h"

@implementation SIUIViewHandler

@synthesize view = view_;

-(void) dealloc {
   self.view = nil;
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
   SIUITapGenerator *tapGenerator = [[SIUITapGenerator alloc] initWithView:self.view];
   [tapGenerator sendEvents];
   [tapGenerator release];
}

-(void) swipe:(SIUISwipeDirection) swipeDirection distance:(int) distance {
   SIUISwipeGenerator *swipeGenerator = [[SIUISwipeGenerator alloc] initWithView:self.view];
   swipeGenerator.swipeDirection = swipeDirection;
   swipeGenerator.distance = distance;
   [swipeGenerator sendEvents];
   [swipeGenerator release];
}

@end
