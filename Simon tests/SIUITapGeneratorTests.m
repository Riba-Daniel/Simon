//
//  SIUITapGeneratorTests.m
//  Simon
//
//  Created by Derek Clarkson on 26/02/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "AbstractTestWithControlsOnView.h"
#import <Simon/SIUITapGenerator.h>

@interface SIUITapGeneratorTests : AbstractTestWithControlsOnView

@end

@implementation SIUITapGeneratorTests

-(void) testTapButton2 {
   self.testViewController.tappedButton = 0;
   SIUITapGenerator *tapGenerator = [[[SIUITapGenerator alloc] initWithView:self.testViewController.button2] autorelease];
   [tapGenerator generateEvents];
   [NSThread sleepForTimeInterval:0.1];
   GHAssertEquals(self.testViewController.tappedButton, 2, @"Button not tapped");
}

-(void) testGestureRecognizerOnLabelTapped {
   self.testViewController.gestureRecognizerTapped = NO;
   SIUITapGenerator *tapGenerator = [[[SIUITapGenerator alloc] initWithView:self.testViewController.tapableLabel] autorelease];
   [tapGenerator generateEvents];
   [NSThread sleepForTimeInterval:0.1];
   GHAssertTrue(self.testViewController.gestureRecognizerTapped, @"gesture recognizer not fired");
}

-(void) testTableViewTappingRowSelects {
   [self scrollTableViewToIndex:0 atScrollPosition:UITableViewScrollPositionTop];
   [NSThread sleepForTimeInterval:0.1];
   SIUITapGenerator *tapGenerator = [[[SIUITapGenerator alloc] initWithView:self.testViewController.tableView] autorelease];
   [tapGenerator generateEvents];
   [NSThread sleepForTimeInterval:0.1];
   GHAssertEquals(self.testViewController.selectedRow, (NSInteger) 2, @"Row not selected");
}

@end
