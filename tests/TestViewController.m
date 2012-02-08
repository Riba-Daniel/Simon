//
//  TestViewController.m
//  Simon
//
//  Created by Derek Clarkson on 7/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "TestViewController.h"

@implementation TestViewController

@synthesize button1 = button1_;
@synthesize button2 = button2_;
@synthesize tabBar = tabBar_;
@synthesize tappedButton = tappedButton_;
@synthesize tappedTabBarItem = tappedTabBarItem_;

- (void)dealloc {
   self.button1 = nil;
   self.button2 = nil;
   self.tabBar = nil;
   [super dealloc];
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return YES;
}

- (IBAction)buttonTapped:(id)sender {
   UIView *button = sender;
   DC_LOG(@"Button tapped: %i", button.tag);
   self.tappedButton = button.tag;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
   DC_LOG(@"Tab bar item tapped: %i", item.tag);
   self.tappedTabBarItem = item.tag;
}
- (void)viewDidUnload {
   [self setTabBar:nil];
   [super viewDidUnload];
}
@end
