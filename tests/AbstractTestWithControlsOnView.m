//
//  TestUtils.m
//  Simon
//
//  Created by Derek Clarkson on 11/09/11.
//  Copyright (c) 2011. All rights reserved.
//

#import "AbstractTestWithControlsOnView.h"
#import <dUsefulStuff/DCCommon.h>
#import <UIKit/UIKit.h>

@implementation AbstractTestWithControlsOnView

-(void) setUpClass {
	[self performSelectorOnMainThread:@selector(addControls) withObject:nil waitUntilDone:YES];
}

-(void) setUp {
	tapped = NO;
}

-(void) tearDownClass {
	[self performSelectorOnMainThread:@selector(removeControls) withObject:nil waitUntilDone:YES];
}

-(void) addControls {
	
	view = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 100, 100)];
	view.backgroundColor = [UIColor grayColor];
	
	button = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	button.frame = CGRectMake(10, 10, 80, 40);
	[button setTitle:@"hello" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:button];
	[view setNeedsLayout];
	
	[[UIApplication sharedApplication].keyWindow addSubview:view];
	[[UIApplication sharedApplication].keyWindow setNeedsLayout];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}

-(void) removeControls {
	[button removeFromSuperview];
	[view removeFromSuperview];
	DC_DEALLOC(button);
	DC_DEALLOC(view);
}

-(IBAction) buttonTapped:(id) sender {
	SI_LOG(@"Button was tapped");	
	tapped = YES;
}


@end
