//
//  main.m
//  Test Navigation App
//
//  Created by Derek Clarkson on 7/16/11.
//  Copyright 2011 Sensis. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Test_Navigation_AppAppDelegate.h"

#import "SISimon.h"

int main(int argc, char *argv[])
{
	int retVal = 0;
	@autoreleasepool {
		
		SIRun();
		
		retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([Test_Navigation_AppAppDelegate class]));
	}
	return retVal;
}
