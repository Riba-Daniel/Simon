//
//  UIViewSimonTests.m
//  Simon
//
//  Created by Derek Clarkson on 17/03/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "UIView+Simon.h"

@interface UIViewSimonTests : GHTestCase

@end

@implementation UIViewSimonTests

-(void) testPointInWindowFromPointInView {
	
	CGPoint pointInView = CGPointMake(10, 10);
	
	UIWindow *window = [[[UIWindow alloc] init] autorelease];
	UIView *view = [[[UIView alloc] init] autorelease];
	[window addSubview:view];
	view.frame = CGRectMake(10, 10, 100, 100);
	
	CGPoint viewInWindow = [view pointInWindowFromPointInView:pointInView];
	
	GHAssertEquals(viewInWindow.x, (CGFloat) 20.0, @"Incorrect X");
	GHAssertEquals(viewInWindow.y, (CGFloat) 20.0, @"Incorrect Y");
	
}

@end
