//
//  TestUtils.m
//  Simon
//
//  Created by Derek Clarkson on 11/09/11.
//  Copyright (c) 2011. All rights reserved.
//

#import "AbstractTestWithControlsOnView.h"
#import <dUsefulStuff/DCCommon.h>
#import <UIKit/UIKit.h>
#import "NSObject+Simon.h"
#import "NSObject+Simon.h"

@implementation AbstractTestWithControlsOnView

@synthesize testViewController = testViewController_;

-(void) setUpClass {
   [super setUpClass];
   [self setupTestView];
}

-(void) setUp {
	[self executeBlockOnMainThread:^{
		DC_LOG(@"Setting up for test");
		[self.testViewController deselectRow];
		self.testViewController.tableView.delaysContentTouches = NO;
	}];
}

-(void) tearDownClass {
   [self removeTestView];
   [super tearDownClass];
}

-(void) setupTestView {
	[self executeBlockOnMainThread:^{
		DC_LOG(@"Loading test view");
		self.testViewController = (TestViewController *)[[[TestViewController alloc] initWithNibName:@"TestView" bundle:[NSBundle mainBundle]] autorelease];
		self.testViewController.view.center = [UIApplication sharedApplication].keyWindow.center;
		
		UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
		[keyWindow addSubview:self.testViewController.view];
		
		// get the view on screen.
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
	}];   
}

-(void) removeTestView {
	[self executeBlockOnMainThread:^{
		DC_LOG(@"Unloading test view");
		[self.testViewController.view removeFromSuperview];
		self.testViewController = nil;
		
		// get the view off screen.
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
	}];   
}

#pragma mark - Helpers
-(void) scrollTableViewToIndex:(int) index atScrollPosition:(UITableViewScrollPosition) position {
   [self executeBlockOnMainThread:^{
		DC_LOG(@"Scrolling to row %i", index);
		[self.testViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:position animated:NO];
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate date]];
	}];
	[NSThread sleepForTimeInterval:0.5];
}

@end
