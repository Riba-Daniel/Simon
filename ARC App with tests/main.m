//
//  main.m
//  ARC App with tests
//
//  Created by Derek Clarkson on 5/03/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "SISimon.h"

int main(int argc, char *argv[])
{
   @autoreleasepool {
      SIRun();
		[SIAppBackpack backpack].autorun = NO;
      return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
   }
}
