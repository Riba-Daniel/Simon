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

-(NSString *)dnName {
	NSString *name =  NSStringFromClass([self.view class]);
	return name;
}

-(NSObject<DNNode> *)dnParentNode {
	return (NSObject<DNNode> *) self.view.superview;
}

-(NSArray *)dnSubNodes {
	// Return a copy as this has been known to change whilst this code is executing.
	return [[self.view.subviews copy] autorelease];	
}

-(BOOL) dnHasAttribute:(NSString *)attribute withValue:(id)value {
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

#pragma mark - View info

-(NSDictionary *) kvcAttributes {
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	if (self.view.tag > 0) {
		[attributes setObject:[NSNumber numberWithInt:self.view.tag] forKey:@"tag"];
	}
	if (self.view.accessibilityIdentifier != nil) {
		[attributes setObject:self.view.accessibilityIdentifier forKey:@"accessibilityIdentifier"];
	}
	if (self.view.accessibilityLabel != nil) {
		[attributes setObject:self.view.accessibilityLabel forKey:@"accessibilityLabel"];
	}
	if (self.view.accessibilityValue != nil) {
		[attributes setObject:self.view.accessibilityValue forKey:@"accessibilityValue"];
	}
	return [attributes count] > 0 ? attributes : nil;
}

@end
