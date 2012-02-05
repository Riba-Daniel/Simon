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

@synthesize testButton1Tapped = testButton1Tapped_;
@synthesize testButton2Tapped = testButton2Tapped_;
@synthesize testView = testView_;
@synthesize testButton1 = testButton1_;
@synthesize testButton2 = testButton2_;

-(void) setUp {
	self.testButton1Tapped = NO;
	self.testButton2Tapped = NO;
}

-(void) setupTestView {

	if (![NSThread isMainThread]) {
      [self performSelectorOnMainThread:@selector(setupTestView) withObject:nil waitUntilDone:YES];
      return;
   }
   
	self.testView = [[[UIView alloc] initWithFrame:CGRectMake(0, 20, 100, 120)] autorelease];
	self.testView.backgroundColor = [UIColor grayColor];
	
	self.testButton1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	self.testButton1.frame = CGRectMake(10, 10, 80, 40);
	[self.testButton1 setTitle:@"hello 1" forState:UIControlStateNormal];
	[self.testButton1 addTarget:self action:@selector(button1Tapped:) forControlEvents:UIControlEventTouchUpInside];

   self.testButton2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	self.testButton2.frame = CGRectMake(10, 60, 80, 40);
	[self.testButton2 setTitle:@"hello 2" forState:UIControlStateNormal];
	[self.testButton2 addTarget:self action:@selector(button2Tapped:) forControlEvents:UIControlEventTouchUpInside];

	[self.testView addSubview:self.testButton1];
	[self.testView addSubview:self.testButton2];
	[self.testView setNeedsLayout];
	
	[[UIApplication sharedApplication].keyWindow addSubview:self.testView];
	[[UIApplication sharedApplication].keyWindow setNeedsLayout];
//	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
}

-(void) removeTestView {

   if (![NSThread isMainThread]) {
      [self performSelectorOnMainThread:@selector(removeTestView) withObject:nil waitUntilDone:YES];
      return;
   }
   
   if (self.testButton1 != nil) {
      [self.testButton1 removeFromSuperview];
      [self.testButton2 removeFromSuperview];
      [self.testView removeFromSuperview];
      self.testButton1 = nil;
      self.testButton2 = nil;
      self.testView = nil;
   }
}

-(IBAction) button1Tapped:(id) sender {
	DC_LOG(@"Button 1 was tapped");	
	self.testButton1Tapped = YES;
}

-(IBAction) button2Tapped:(id) sender {
	DC_LOG(@"Button 2 was tapped");	
	self.testButton2Tapped = YES;
}


@end
