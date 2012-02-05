//
//  TestUtils.h
//  Simon
//
//  Created by Derek Clarkson on 11/09/11.
//  Copyright (c) 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>

@interface AbstractTestWithControlsOnView : GHTestCase {
}

@property (retain, nonatomic) UIView *testView;
@property (nonatomic) BOOL testButton1Tapped;
@property (nonatomic) BOOL testButton2Tapped;
@property (retain, nonatomic) UIButton *testButton1;
@property (retain, nonatomic) UIButton *testButton2;

-(void) setupTestView;
-(void) removeTestView;
-(IBAction) button1Tapped:(id) sender;
-(IBAction) button2Tapped:(id) sender;

@end
