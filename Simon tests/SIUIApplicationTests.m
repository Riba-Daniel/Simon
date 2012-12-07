//
//  SIUIUtils.m
//  Simon
//
//  Created by Derek Clarkson on 7/23/11.
//  Copyright 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>
#import <UIKit/UIKit.h>

#import <Simon/SIUIApplication.h>
#import <Simon/UIView+Simon.h>
#import <Simon/UIView+Simon.h>
#import <Simon/SIConstants.h>
#import <dNodi/dNodi.h>
#import "AbstractTestWithControlsOnView.h"
#import <Simon/SIUITooManyFoundException.h>
#import <Simon/SIUINotFoundException.h>
#import <Simon/SISyntaxException.h>
#import <Simon/SIUIException.h>
#import <Simon/NSObject+Simon.h>
#import <Simon/SIUINotAnInputViewException.h>

@interface SIUIApplicationTests : AbstractTestWithControlsOnView

@end

@implementation SIUIApplicationTests

#pragma mark - finding

-(void) testViewWithQueryFindsButton {
	UIView<DNNode> *button = [[SIUIApplication application] findViewWithQuery:@"//UIRoundedRectButton/UIButtonLabel[text='Button 1']/.."];
	GHAssertEqualStrings(button.dnName, @"UIRoundedRectButton", @"Search bar not returned");
}

-(void) testViewWithQueryThrowsIfNotFound {
	@try {
      [[SIUIApplication application] findViewWithQuery:@"//abc"];
      GHFail(@"Exception not thrown");
   } 
	@catch (SIUINotFoundException *exception) {
      GHAssertEqualStrings(exception.name, NSStringFromClass([SIUINotFoundException class]), @"Incorrect domain");
      GHAssertEqualStrings(exception.reason, @"Path //abc failed to find anything.", @"Reason incorrect");
   }
}

-(void) testViewWithQueryThrowsIfTooManyFound {
	@try {
      [[SIUIApplication application] findViewWithQuery:@"//UISegmentLabel"];
      GHFail(@"Exception not thrown");
   }
   @catch (SIUITooManyFoundException *exception) {
      GHAssertEqualStrings(exception.name, NSStringFromClass([SIUITooManyFoundException class]), @"Incorrect domain");
      GHAssertEqualStrings(exception.reason, @"Path //UISegmentLabel should return one view only, got 2 instead.", @"Reason incorrect");
   }
}

-(void) testViewWithQueryThrowsIfInvalidXPath {
	@try {
      [[SIUIApplication application] findViewWithQuery:@"//["];
      GHFail(@"Exception not thrown");
   }
   @catch (SISyntaxException *exception) {
      GHAssertEqualStrings(exception.name, NSStringFromClass([SISyntaxException class]), nil);
      GHAssertEqualStrings(exception.reason, @"Query appears to be incomplete.", nil);
   }
}

-(void) testFindViewsWithQueryFindsAllButtons {
   [[SIUIApplication application] logUITree];
	NSArray *controls = [[SIUIApplication application] findViewsWithQuery:@"//UITableViewCell"];
	GHAssertTrue([controls count] > 0, @"Nothing returned");
	for (UIView *view in controls) {
		GHAssertTrue([view isKindOfClass:[UITableViewCell class]], @"Non-table view cell found");
	}
}

-(void) testIsViewPresentReturnsYes {
	GHAssertTrue([[SIUIApplication application] isViewPresent:@"//UIRoundedRectButton/UIButtonLabel[text='Button 1']/.."], @"Should have returned YES");
}

-(void) testIsViewPresentReturnsNo {
	GHAssertFalse([[SIUIApplication application] isViewPresent:@"xxxx"], @"Should have returned NO");
}

#pragma mark - logUITree

-(void) testLogUITreeDumpsToConsoleWithoutError {
	[[SIUIApplication application] logUITree]; 
}

#pragma mark - taps

-(void) testTapViewTapsButton1 {
   self.testViewController.tappedButton = 0;
   UIView *tappedView = [[SIUIApplication application] tapView:self.testViewController.button1];
   GHAssertEquals(self.testViewController.tappedButton, 1, @"Button not tapped");
	GHAssertEqualObjects(tappedView, self.testViewController.button1, @"button not returned");
}

-(void) testTapViewWithQueryTapsButton1 {
   self.testViewController.tappedButton = 0;
   UIView *tappedView = [[SIUIApplication application] tapViewWithQuery:@"//UIRoundedRectButton[titleLabel.text='Button 1']"];
   GHAssertEquals(self.testViewController.tappedButton, 1, @"Button not tapped");
	GHAssertEqualObjects(tappedView, self.testViewController.button1, @"button not returned");
}

-(void) testTapViewWithQueryTapsButton2 {
   self.testViewController.tappedButton = 0;
   UIView *tappedView = [[SIUIApplication application] tapViewWithQuery:@"//UIRoundedRectButton[titleLabel.text='Button 2']"];
   GHAssertEquals(self.testViewController.tappedButton, 2, @"Button not tapped");
	GHAssertEqualObjects(tappedView, self.testViewController.button2, @"button not returned");
}

-(void) testTapTabBarButtonWithLabelTapsButton1 {
   self.testViewController.tappedTabBarItem = 0;
   [[SIUIApplication application] tapTabBarButtonWithLabel:@"Favorites"];
   GHAssertEquals(self.testViewController.tappedTabBarItem, 1, @"Tab bar item not tapped");
}

-(void) testTapTabBarButtonWithLabelTapsButton2 {
   self.testViewController.tappedTabBarItem = 0;
   [[SIUIApplication application] tapTabBarButtonWithLabel:@"More"];
   GHAssertEquals(self.testViewController.tappedTabBarItem, 2, @"Tab bar item not tapped");
}

-(void) testTapButtonWithLabel {
   self.testViewController.tappedButton = 0;
   [[SIUIApplication application] tapButtonWithLabel:@"Button 1"];
   GHAssertEquals(self.testViewController.tappedButton, 1, @"Button not tapped");
}

-(void) testTapButtonWithLabelAndWait {
	
   self.testViewController.tappedButton = 0;
   
   NSDate *before = [NSDate date];
   [[SIUIApplication application] tapButtonWithLabel:@"Button 1" andWait:1.0];
   NSTimeInterval diff = [before timeIntervalSinceNow];
   
   GHAssertEquals(self.testViewController.tappedButton, 1, @"Button not tapped");
   GHAssertLessThan(diff, -1.0, @"Not enough time passed");
}

#pragma mark - Swipes

-(void) testSwipeSliderUsingView {
   self.testViewController.slider.value = 5;
   UIView *swipedView = [[SIUIApplication application] swipeView:self.testViewController.slider inDirection:SIUISwipeDirectionRight forDistance: 80];
   
   GHAssertEquals(round(self.testViewController.slider.value), 8.0, @"Slider not swiped.");
	GHAssertEquals(swipedView, self.testViewController.slider, @"Incorrect view returned");
}

-(void) testSwipeSliderUsingQuery {
   self.testViewController.slider.value = 5;
   UIView *swipedView = [[SIUIApplication application] swipeViewWithQuery:@"//UISlider" inDirection:SIUISwipeDirectionRight forDistance: 80];
   
   GHAssertEquals(round(self.testViewController.slider.value), 8.0, @"Slider not swiped.");
	GHAssertEquals(swipedView, self.testViewController.slider, @"Incorrect view returned");
}

-(void) testTableViewSwipingDown {
   [[SIUIApplication application] logUITree];
   self.testViewController.selectedRow = 0;
   [self scrollTableViewToIndex:5 atScrollPosition:UITableViewScrollPositionMiddle];
	
   [[SIUIApplication application] swipeViewWithQuery:@"//UIView//UITableView" inDirection:SIUISwipeDirectionDown forDistance:80];
   
   [NSThread sleepForTimeInterval:0.1];
   [[SIUIApplication application] tapViewWithQuery:@"//UIView//UITableView"];
   
   [NSThread sleepForTimeInterval:0.1];
   GHAssertEquals(self.testViewController.selectedRow, (NSInteger)3, @"Swipe or tap failed");
}


#pragma mark - Pauses and Waits

-(void) testPauseFor {
   NSDate *before = [NSDate date];
   [[SIUIApplication application] pauseFor:0.5];
   NSTimeInterval diff = [before timeIntervalSinceNow];
   GHAssertLessThan(diff, -0.5, @"Not enough time passed");
}

-(void) testWaitFor {
   
   self.testViewController.displayLabel.text = @"...";
   [[NSRunLoop mainRunLoop] runUntilDate:[NSDate date]];
	
   [[SIUIApplication application] tapButtonWithLabel:@"Wait for it!"];
   GHAssertEqualStrings(self.testViewController.displayLabel.text, @"...", @"Label should not be updated yet");
   UIView *label = [[SIUIApplication application] waitForViewWithQuery:@"//UILabel[text='Clicked!']" retryInterval:0.5 maxRetries:5];
   GHAssertNotNil(label, @"Nothing returned");
   GHAssertEqualStrings(self.testViewController.displayLabel.text, @"Clicked!", @"Button should have updated by now");
}

-(void) testWaitForExitsOnOtherException {
	@try {
      [[SIUIApplication application] waitForViewWithQuery:@"//[" retryInterval:0.5 maxRetries:5];
      GHFail(@"Exception not thrown");
   }
   @catch (SISyntaxException *exception) {
      // Good
   }
}

-(void) testWaitForExceedsRetryCount {
   
   self.testViewController.displayLabel.text = @"...";
   [[NSRunLoop mainRunLoop] runUntilDate:[NSDate date]];
	
   @try {
      [[SIUIApplication application] waitForViewWithQuery:@"//UILabel[text='Wait for it!']" retryInterval:0.5 maxRetries:5];
      GHFail(@"Exception not thrown");
   }
   @catch (SIUIException *exception) {
      // Good
   }
}

#pragma mark - Animation

-(void) testWaitForAnimationFinish {
	
	dispatch_queue_t mainQueue = dispatch_get_main_queue();
   NSDate *before = [NSDate date];
	dispatch_async(mainQueue, ^{
		CGPoint originalCenter = self.testViewController.waitForItButton.center;
		[UIView animateWithDuration:1.0 
									 delay:0.0
								  options:UIViewAnimationOptionAutoreverse
							  animations: ^{
								  self.testViewController.waitForItButton.center = CGPointMake(originalCenter.x + 100, originalCenter.y); 
							  }
							  completion:^(BOOL finished) {
								  self.testViewController.waitForItButton.center = originalCenter;
							  }];
	});
	
	[[SIUIApplication application] waitForAnimationEndOnViewWithQuery:@"//UIRoundedRectButton[titleLabel.text='Wait for it!']" retryInterval:0.8];
	
   NSTimeInterval diff = fabs([before timeIntervalSinceNow]);
	GHAssertGreaterThan(diff, 2.0, @"not long enough, animation not finished.");
	
}

#pragma mark - Text 

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

-(void) testEnterTextIntoViewWithQuery {
	[self executeBlockOnMainThread:^{
		self.testViewController.textField.text = @"";
	}];
	
	NSString *text = @"Hello world";
	[[SIUIApplication application] enterText:text intoViewWithQuery:@"//UITextField[0]"];
	
	__block NSString *enteredText = nil;
	[self executeBlockOnMainThread:^{
		enteredText = [self.testViewController.textField.text retain];
	}];
	[enteredText autorelease];
	GHAssertEqualStrings(enteredText, text, @"Text not correct");
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
