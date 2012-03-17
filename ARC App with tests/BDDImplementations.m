//
//  BDDImplementations.m
//  Simon
//
//  Created by Derek Clarkson on 5/03/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SISimon.h"
#import <dUsefulStuff/DCCommon.h>

@interface BDDImplementations : NSObject
@end

#define LABEL_FIRST @"//UILabel[@text='First View']"
#define LABEL_SECOND @"//UILabel[@text='Second View']"

@implementation BDDImplementations

SIMapStepToSelector(@"Given I am on the first page", startOnFirstScreen);
-(void) startOnFirstScreen {
	SIPrintCurrentWindowTree();
	DC_LOG(@"%@", LABEL_FIRST);
	if (!SIIsViewPresent(LABEL_FIRST)) {
		SITapTabBarButtonWithLabel(@"First");
		SIPauseFor(0.5);
	}
	SIAssertViewPresent(LABEL_FIRST);
}

SIMapStepToSelector(@"Given I am on the second page", startOnSecondScreen);
-(void)startOnSecondScreen {
	if (!SIIsViewPresent(LABEL_SECOND)) {
		SITapTabBarButtonWithLabel(@"Second");
		SIPauseFor(0.5);
	}
	SIAssertViewPresent(LABEL_SECOND);
}

SIMapStepToSelector(@"Then goto the second page", gotoSecondScreen);
-(void) gotoSecondScreen {
	SIAssertViewNotPresent(LABEL_SECOND);
	SITapTabBarButtonWithLabel(@"Second");
	SIPauseFor(0.5);
	SIAssertViewPresent(LABEL_SECOND);
}

SIMapStepToSelector(@"Then I can tap a button", tapSecondPageHelloButton);
-(void) tapSecondPageHelloButton {
	SITapButtonWithLabel(@"Hello");
}

SIMapStepToSelector(@"and see \"(.*)\" in the label", verifyLabel:);
-(void) verifyLabel:(NSString *) text {
	SIAssertLabelTextEquals(@"//UILabel[1]", @"hello");
}

SIMapStepToSelector(@"then I can enter \"(.*)\" into the name field", enterTextIntoNameField:);
-(void) enterTextIntoNameField:(NSString *) text {
	SITapView(@"//UITextField[1]");
}

@end
