//
//  TestUtils.h
//  Simon
//
//  Created by Derek Clarkson on 11/09/11.
//  Copyright (c) 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "TestViewController.h"

@interface AbstractTestWithControlsOnView : GHTestCase {
}

@property (retain, nonatomic) TestViewController *testViewController;

-(void) setupTestView;
-(void) removeTestView;
-(void) scrollTableViewToIndex:(int) index atScrollPosition:(UITableViewScrollPosition) position;

