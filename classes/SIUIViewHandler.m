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
#import "NSObject+Simon.h"

// We need access to the private API of the keyboard layout so we can send keys.
@interface UIKeyboardLayout : UIView
- (id)simulateTouchForCharacter:(id)arg1 errorVector:(CGPoint)arg2 shouldTypeVariants:(BOOL)arg3 baseKeyForVariants:(BOOL)arg4;
- (BOOL)performReturnAction;
@end
@interface UIKeyboardImpl : UIView
- (void)_setAutocorrects:(BOOL)arg1;
- (id)returnKeyDisplayName;
@end

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
	
	// Check for special attribute requests.
	if ([attribute isEqualToString:@"protocol"]) {
		return [self.view conformsToProtocol:NSProtocolFromString(value)];
	}
	if ([attribute isEqualToString:@"isKindOfClass"]) {
		return [self.view isKindOfClass:NSClassFromString(value)];
	}
	
	// Use KVC to test the value.
	id propertyValue = [self.view valueForKeyPath:attribute];
	return [propertyValue isEqual:value];
}

#pragma mark - SIUIAction

-(void) tap {
	DC_LOG(@"Tapping %p", self.view);
   SIUITapGenerator *tapGenerator = [[SIUITapGenerator alloc] initWithView:self.view];
   [tapGenerator generateEvents];
   [tapGenerator release];
}

-(void) tapAtPoint:(CGPoint)atPoint {
   SIUITapGenerator *tapGenerator = [[SIUITapGenerator alloc] initWithView:self.view];
	tapGenerator.tapPoint = atPoint;
   [tapGenerator generateEvents];
   [tapGenerator release];
}

-(void) swipe:(SIUISwipeDirection) swipeDirection distance:(int) distance {
   SIUISwipeGenerator *swipeGenerator = [[SIUISwipeGenerator alloc] initWithView:self.view];
   swipeGenerator.swipeDirection = swipeDirection;
   swipeGenerator.distance = distance;
   [swipeGenerator generateEvents];
   [swipeGenerator release];
}

-(void) enterText:(NSString *) text keyRate:(NSTimeInterval) keyRate autoCorrect:(BOOL) autoCorrect {
	
	// Here we assume that the 
	
	[self executeBlockOnMainThread:^{
		
		// First navigate the keyboard hierarchy to the keyboard layout.
		NSArray *windows = [UIApplication sharedApplication].windows;
		UIWindow *effectsWindow = [windows objectAtIndex:1];
		UIView *hostView = (UIView *) [effectsWindow.subviews objectAtIndex:0];
		UIView *keyboardAuto = (UIView *) [hostView.subviews objectAtIndex:0];
		UIKeyboardImpl *kbImpl = (UIKeyboardImpl *) [keyboardAuto.subviews objectAtIndex:0];
		UIKeyboardLayout *kbLayout = (UIKeyboardLayout *) [kbImpl.subviews objectAtIndex:0];
		
		// Turn on or off auto correct. 
		[kbImpl _setAutocorrects:autoCorrect];
		
		// Loop and send each character.
		NSRange subStringRange;
		for (int i = 0; i < [text length]; i++) {

			subStringRange = NSMakeRange(i,1);
			
			// shouldTypeVariant controls whether characters which are variants of a base key should be typed.
			// baseKeyForVariants controls wether to type the base key instead of a variant.
			id sentChar = [kbLayout simulateTouchForCharacter:[text substringWithRange:subStringRange]
															  errorVector:CGPointMake(0,0) 
													 shouldTypeVariants:YES 
													 baseKeyForVariants:NO];
			
			[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:keyRate]];
			DC_LOG(@"Sent character %@", sentChar);
		}
		DC_LOG(@"Text entry finished, return key %@", [kbImpl returnKeyDisplayName]);
	}];
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
