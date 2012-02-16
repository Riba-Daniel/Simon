//
//  ViewController.m
//  EventLogger
//
//  Created by Derek Clarkson on 15/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "ViewController.h"
#import <dUsefulStuff/DCCommon.h>

@implementation ViewController

@synthesize buttonA = buttonA_;
@synthesize buttonB = buttonB_;
-(IBAction) buttonATapped:(id) sender {
   DC_LOG(@"Button A tapped");
}
-(IBAction) buttonBTapped:(id) sender {
   DC_LOG(@"Button B tapped");
}

@end
