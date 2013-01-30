//
//  SIUIApplication+Text.m
//  Simon
//
//  Created by Derek Clarkson on 4/01/13.
//  Copyright (c) 2013 Sensis. All rights reserved.
//

#import <Simon/SIUIApplication+Text.h>
#import <Simon/SIUIApplication+Searches.h>
#import <Simon/SIUINotAnInputViewException.h>
#import <Simon/SIUIApplication+Actions.h>

@implementation SIUIApplication (Text)

-(void) enterText:(NSString *) text intoView:(UIView *) view {
	
	if (![view conformsToProtocol:@protocol(UITextInput)]) {
		@throw [SIUINotAnInputViewException exceptionWithReason: [NSString stringWithFormat:@"%@ is not an input field.", NSStringFromClass([view class])]];
	}
	
	// If the view does not have focus then make sure it does.
	if (![view isFirstResponder]) {
		[self tap:view];
	}
	
	// Enter the text.
	[[self viewHandlerForView:view] enterText:text keyRate:0.1 autoCorrect: ! self.disableKeyboardAutocorrect];
	
}

@end
