//
//  SIUIApplication_TextTests.m
//  Simon
//
//  Created by Derek Clarkson on 4/01/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/NSObject+Simon.h>
#import <Simon/SIUIApplication.h>
#import <Simon/SIUIApplication+Text.h>
#import <Simon/SIUINotAnInputViewException.h>
#import "AbstractTestWithControlsOnView.h"

@interface SIUIApplication_TextTests : AbstractTestWithControlsOnView

@end

@implementation SIUIApplication_TextTests

-(void) testEnterTextIntoView {
	[self executeBlockOnMainThread:^{
		self.testViewController.textField.text = @"";
	}];
	
	NSString *text = @"ABC DEF GHI klm nop qrs tuv-w.y,y:z";
	[SIUIApplication application].disableKeyboardAutocorrect = YES;
	[[SIUIApplication application] enterText:text intoView:self.testViewController.textField];
	
	__block NSString *enteredText = nil;
	[self executeBlockOnMainThread:^{
		enteredText = [self.testViewController.textField.text retain];
	}];
	[enteredText autorelease];
	GHAssertEqualStrings(enteredText, text, @"Text not correct");
}

-(void) testEnterTextIntoViewFailIfNotCorrectInputProtocol {
	@try {
		[[SIUIApplication application] enterText:@"" intoView:self.testViewController.waitForItButton];
		GHFail(@"Exception not thrown");
	}
	@catch (SIUINotAnInputViewException *exception) {
		// Good
	}
}

-(void) testEnterPhoneNumber {
	
	[self executeBlockOnMainThread:^{
		self.testViewController.phoneNumberField.text = @"";
	}];
	
	NSString *text = @"0404 053 463\n";
	[[SIUIApplication application] enterText:text intoView:self.testViewController.phoneNumberField];
	
	__block NSString *enteredText = nil;
	[self executeBlockOnMainThread:^{
		enteredText = [self.testViewController.phoneNumberField.text retain];
	}];
	[enteredText autorelease];
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		GHAssertEqualStrings(enteredText, @"0404 053 463", @"Text not correct");
	} else {
		GHAssertEqualStrings(enteredText, @"0404053463", @"Text not correct");
	}
}

@end
