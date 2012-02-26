//
//  SIUITapGeneratorTests.m
//  Simon
//
//  Created by Derek Clarkson on 26/02/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "AbstractTestWithControlsOnView.h"
#import "SIUITapGenerator.h"

@interface SIUITapGeneratorTests : AbstractTestWithControlsOnView

@end

@implementation SIUITapGeneratorTests

-(void) testTapButton2 {
   self.testViewController.tappedButton = 0;
   SIUITapGenerator *tapGenerator = [[[SIUITapGenerator alloc] initWithView:self.testViewController.button2] autorelease];
   [tapGenerator sendEvents];
   [NSThread sleepForTimeInterval:0.1];
   GHAssertEquals(self.testViewController.tappedButton, 2, @"Button not tapped");
}

@end
