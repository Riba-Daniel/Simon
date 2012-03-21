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

@synthesize testViewController = testViewController_;

-(void) setUpClass {
   [super setUpClass];
   [self setupTestView];
}

-(void) tearDownClass {
   [self removeTestView];
   [super tearDownClass];
}

-(void) setupTestView {
   
	if (![NSThread isMainThread]) {
      [self performSelectorOnMainThread:@selector(setupTestView) withObject:nil waitUntilDone:YES];
      return;
   }
   
   DC_LOG(@"Loading test view");
   self.testViewController = (TestViewController *)[[[TestViewController alloc] initWithNibName:@"TestView" bundle:[NSBundle mainBundle]] autorelease];
   self.testViewController.view.center = [UIApplication sharedApplication].keyWindow.center;
	[[UIApplication sharedApplication].keyWindow addSubview:self.testViewController.view];
   
   // get the view on screen.
   [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
   
}

-(void) removeTestView {
   
   if (![NSThread isMainThread]) {
      [self performSelectorOnMainThread:@selector(removeTestView) withObject:nil waitUntilDone:YES];
      return;
   }

	DC_LOG(@"Unloading test view");
   [self.testViewController.view removeFromSuperview];
   self.testViewController = nil;

   // get the view off screen.
   [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];

}

#pragma mark - Helpers
-(void) scrollTableViewToIndex:(int) index atScrollPosition:(UITableViewScrollPosition) position {
   
   // Whatch for the main thread because re-running a test from GHUnit test view runs it on the main thread. Known bug in GHUnit.
   if ([NSThread isMainThread]) {
      [self.testViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:position animated:NO];
      [[NSRunLoop currentRunLoop] runUntilDate: [NSDate date]];
   } else {
      dispatch_queue_t mainQ = dispatch_get_main_queue();
      dispatch_sync(mainQ, ^{
         [self.testViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:position animated:NO];
         [[NSRunLoop currentRunLoop] runUntilDate: [NSDate date]];
      });
   }   
}

@end
