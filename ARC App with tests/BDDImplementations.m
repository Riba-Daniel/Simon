//
//  BDDImplementations.m
//  Simon
//
//  Created by Derek Clarkson on 5/03/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import <Simon/Simon.h>

@interface BDDImplementations : NSObject
@end

#define LABEL_FIRST @"//UILabel[text='First View']"
#define LABEL_SECOND @"//UILabel[text='Second View']"

@implementation BDDImplementations

mapStepToSelector(@"Given I am on the first page", startOnFirstScreen);
-(void) startOnFirstScreen {
	printCurrentWindowTree();
	DC_LOG(@"%@", LABEL_FIRST);
	if (!isPresent(LABEL_FIRST)) {
		tap(buttonWithLabel(@"First"));
		pauseFor(0.5);
	}
	assertViewPresent(LABEL_FIRST);
}

mapStepToSelector(@"Given I am on the second page", startOnSecondScreen);
-(void)startOnSecondScreen {
	if (!isPresent(LABEL_SECOND)) {
		tap(buttonWithLabel(@"Second"));
		pauseFor(0.5);
	}
	assertViewPresent(LABEL_SECOND);
}

mapStepToSelector(@"Then goto the second page", gotoSecondScreen);
-(void) gotoSecondScreen {
	assertViewNotPresent(LABEL_SECOND);
	tap(buttonWithLabel(@"Second"));
	pauseFor(0.5);
	assertViewPresent(LABEL_SECOND);
}

mapStepToSelector(@"Then I can tap a button", tapSecondPageHelloButton);
-(void) tapSecondPageHelloButton {
	tap(buttonWithLabel(@"Hello"));
}

mapStepToSelector(@"and see \"(.*)\" in the label", verifyLabel:);
-(void) verifyLabel:(NSString *) text {
	assertLabelTextEquals(viewWithQuery(@"//UILabel[1]"), @"hello");
}

mapStepToSelector(@"then I can enter \"(.*)\" into the name field", enterTextIntoNameField:);
-(void) enterTextIntoNameField:(NSString *) text {
	UITextField *field = (UITextField *)viewWithQuery(@"//UITextField[1]");
	tap(field);
	pauseFor(0.5);
	enterText(field, @"Hello there!");
}

@end
