//
//  SIUIApplication_TimeTests.m
//  Simon
//
//  Created by Derek Clarkson on 4/01/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/NSObject+Simon.h>
#import <Simon/SIUIApplication.h>
#import <Simon/SIUIApplication+Time.h>
#import <Simon/SIUIApplication+Actions.h>
#import <Simon/SISyntaxException.h>
#import <Simon/SIUIException.h>
#import "AbstractTestWithControlsOnView.h"

@interface SIUIApplication_TimeTests : AbstractTestWithControlsOnView

@end

@implementation SIUIApplication_TimeTests
-(void) testPauseFor {
	NSDate *before = [NSDate date];
	[[SIUIApplication application] pauseFor:0.5];
	NSTimeInterval diff = [before timeIntervalSinceNow];
	GHAssertLessThan(diff, -0.5, @"Not enough time passed");
}

-(void) testWaitForViewWithQuery {
	
	self.testViewController.displayLabel.text = @"...";
	[[NSRunLoop mainRunLoop] runUntilDate:[NSDate date]];
	
	[[SIUIApplication application] tap:[[SIUIApplication application] buttonWithLabel: @"Wait for it!"]];
	GHAssertEqualStrings(self.testViewController.displayLabel.text, @"...", @"Label should not be updated yet");
	
	UIView *label = [[SIUIApplication application] waitForViewWithQuery:@"//UILabel[text='Clicked!']" retryInterval:0.5 maxRetries:5];
	
	GHAssertNotNil(label, @"Nothing returned");
	GHAssertEqualStrings(self.testViewController.displayLabel.text, @"Clicked!", @"Button should have updated by now");
}

-(void) testWaitForViewWithQueryExitsOnOtherException {
	@try {
		[[SIUIApplication application] waitForViewWithQuery:@"//[" retryInterval:0.5 maxRetries:5];
		GHFail(@"Exception not thrown");
	}
	@catch (SISyntaxException *exception) {
		// Good
	}
}

-(void) testWaitForViewWithQueryExceedsRetryCount {
	
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

@end
