//
//  SIUIApplication_ActionsTests.m
//  Simon
//
//  Created by Derek Clarkson on 4/01/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/SIUIApplication.h>
#import <Simon/SIUIApplication+Actions.h>
#import "AbstractTestWithControlsOnView.h"
#import <PublicAutomation/UIAutomationBridge.h>

@interface SIUIApplication_ActionsTests : AbstractTestWithControlsOnView

@end

@implementation SIUIApplication_ActionsTests
#pragma mark - taps

-(void) testTapTapsButton1 {
	self.testViewController.tappedButton = 0;
	[[SIUIApplication application] tap:self.testViewController.button1];
	[NSThread sleepForTimeInterval:0.1];
	
	GHAssertEquals(self.testViewController.tappedButton, 1, nil);
}

-(void) testTapTapsButton2 {
	self.testViewController.tappedButton = 0;
	[[SIUIApplication application] tap:self.testViewController.button2];
	[NSThread sleepForTimeInterval:0.1];
	
	GHAssertEquals(self.testViewController.tappedButton, 2, nil);
}

-(void) testTapAtPointTapsButton2 {
	self.testViewController.tappedButton = 0;
	[[SIUIApplication application] tap:self.testViewController.button2 atPoint:CGPointMake(20, 10)];
	[NSThread sleepForTimeInterval:0.1];
	
	GHAssertEquals(self.testViewController.tappedButton, 2, nil);
}

-(void) testTappedTableViewWithDelayTouchesOn {
	[self scrollTableViewToIndex:5 atScrollPosition:UITableViewScrollPositionMiddle];
	self.testViewController.tableView.delaysContentTouches = YES;
	[[SIUIApplication application] tap:self.testViewController.tableView];
	
	[NSThread sleepForTimeInterval:0.3];
	GHAssertEquals(self.testViewController.selectedRow, (NSInteger) 5, @"an error");
}

-(void) testTappedTableViewWithDelayTouchesOff {
	[self scrollTableViewToIndex:5 atScrollPosition:UITableViewScrollPositionMiddle];
	self.testViewController.tableView.delaysContentTouches = NO;
	[[SIUIApplication application] tap:self.testViewController.tableView];

	[NSThread sleepForTimeInterval:0.1];
	GHAssertEquals(self.testViewController.selectedRow, (NSInteger)5, nil);
}

#pragma mark - Swipes

-(void) testSwipeSliderUsingView {
	self.testViewController.slider.value = 5;
	[[SIUIApplication application] swipe:self.testViewController.slider inDirection:SIUISwipeDirectionRight forDistance: 80];
	GHAssertEquals(round(self.testViewController.slider.value), 8.0, nil);
}

-(void) testTableViewSwipingDown {
	[self scrollTableViewToIndex:7 atScrollPosition:UITableViewScrollPositionMiddle];
	
	[[SIUIApplication application] swipe:self.testViewController.tableView inDirection:SIUISwipeDirectionDown forDistance:80];
	
	[NSThread sleepForTimeInterval:1.0];
	[[SIUIApplication application] tap:self.testViewController.tableView];
	
	[NSThread sleepForTimeInterval:0.2];
	GHAssertEquals(self.testViewController.selectedRow, (NSInteger) 5, nil);
}

-(void) testTableViewSwipingUp {
	[self scrollTableViewToIndex:3 atScrollPosition:UITableViewScrollPositionMiddle];
	
	[[SIUIApplication application] swipe:self.testViewController.tableView inDirection:SIUISwipeDirectionUp forDistance:80];
	
	[NSThread sleepForTimeInterval:1.0];
	[[SIUIApplication application] tap:self.testViewController.tableView];
	
	[NSThread sleepForTimeInterval:0.2];
	GHAssertEquals(self.testViewController.selectedRow, (NSInteger) 6, nil);
}

@end
