//
//  SIUIUtils.m
//  Simon
//
//  Created by Derek Clarkson on 7/23/11.
//  Copyright 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>

#import <Simon/SIUIApplication.h>
#import <Simon/SIUIApplication+Actions.h>

#import <Simon/UIView+Simon.h>
#import <Simon/SIConstants.h>
#import <dNodi/dNodi.h>
#import "AbstractTestWithControlsOnView.h"
#import <Simon/SIUITooManyFoundException.h>
#import <Simon/SIUINotFoundException.h>
#import <Simon/SISyntaxException.h>
#import <Simon/SIUIException.h>
#import <Simon/NSObject+Simon.h>
#import <Simon/SIUINotAnInputViewException.h>

@interface SIUIApplicationTests : AbstractTestWithControlsOnView

@end

@implementation SIUIApplicationTests

-(void) testLogUITreeDumpsToConsoleWithoutError {
	[[SIUIApplication application] logUITree];
}

@end
