//
//  SIUIiPadKeyboardTests.m
//  Simon
//
//  Created by Derek Clarkson on 18/03/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "SIUIKeyboard.h"
#import "AbstractTestWithControlsOnView.h"


@interface SIUIKeyboardTests : AbstractTestWithControlsOnView

@end

@implementation SIUIKeyboardTests

-(void) testSimpleText {
	[[NSRunLoop mainRunLoop] runUntilDate:[NSDate date]];
	SIPrintCurrentWindowTree();
	//SITapView(@"//UITextField");
	//SIUIKeyboard *keyboard = [[[SIUIKeyboard alloc] initWithView:nil] autorelease];
	//[keyboard enterText:@"Hello" keyRate:0.1];
}

@end
