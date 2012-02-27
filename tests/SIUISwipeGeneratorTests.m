//
//  SIUISwipeGeneratorTests.m
//  Simon
//
//  Created by Derek Clarkson on 26/02/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "AbstractTestWithControlsOnView.h"
#import "SIUISwipeGenerator.h"
#import "SIUITapGenerator.h"

@interface SIUISwipeGeneratorTests : AbstractTestWithControlsOnView

@end

@implementation SIUISwipeGeneratorTests
-(void) testSwipeSliderRight {
   self.testViewController.slider.value = 5.0;

   SIUISwipeGenerator *swipeGenerator = [[[SIUISwipeGenerator alloc] initWithView:self.testViewController.slider] autorelease];
   swipeGenerator.swipeDirection = SIUISwipeDirectionRight;
   swipeGenerator.distance = 100;
   [swipeGenerator sendEvents];
   
   [NSThread sleepForTimeInterval:0.5];
   GHAssertEquals(round(self.testViewController.slider.value), 8.0, @"Slider not swiped.");
}

-(void) testSliderSwipingLeft {
   self.testViewController.slider.value = 5.0;
   
   SIUISwipeGenerator *swipeGenerator = [[[SIUISwipeGenerator alloc] initWithView:self.testViewController.slider] autorelease];
   swipeGenerator.swipeDirection = SIUISwipeDirectionLeft;
   swipeGenerator.distance = 100;
   [swipeGenerator sendEvents];

   [NSThread sleepForTimeInterval:0.5];
   GHAssertEquals(round(self.testViewController.slider.value), 2.0, @"Slider not swiped.");
}

-(void) testTableViewSwipingUp {
   self.testViewController.selectedRow = 0;
   [self scrollTableViewToIndex:5 atScrollPosition:UITableViewScrollPositionMiddle];
   
   SIUISwipeGenerator *swipeGenerator = [[[SIUISwipeGenerator alloc] initWithView:self.testViewController.tableView] autorelease];
   swipeGenerator.swipeDirection = SIUISwipeDirectionUp;
   [swipeGenerator sendEvents];
   
   [NSThread sleepForTimeInterval:0.1];
   SIUITapGenerator *tapGenerator = [[[SIUITapGenerator alloc] initWithView:self.testViewController.tableView] autorelease];
   [tapGenerator sendEvents];
   
   [NSThread sleepForTimeInterval:0.1];
   GHAssertEquals(self.testViewController.selectedRow, (NSInteger)7, @"Swipe or tap failed");
   
   GHAssertGreaterThanOrEqual([self.testViewController dragDuration], 0.45, @"Drag too fast");
}

-(void) testTableViewSwipingDown {
   self.testViewController.selectedRow = 0;
   [self scrollTableViewToIndex:5 atScrollPosition:UITableViewScrollPositionMiddle];

   SIUISwipeGenerator *swipeGenerator = [[[SIUISwipeGenerator alloc] initWithView:self.testViewController.tableView] autorelease];
   swipeGenerator.swipeDirection = SIUISwipeDirectionDown;
   [swipeGenerator sendEvents];

   [NSThread sleepForTimeInterval:0.1];
   SIUITapGenerator *tapGenerator = [[[SIUITapGenerator alloc] initWithView:self.testViewController.tableView] autorelease];
   [tapGenerator sendEvents];
   
   [NSThread sleepForTimeInterval:0.1];
   GHAssertEquals(self.testViewController.selectedRow, (NSInteger)3, @"Swipe or tap failed");
   
   GHAssertGreaterThanOrEqual([self.testViewController dragDuration], 0.45, @"Drag too fast");
}

@end
