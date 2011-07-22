//
//  main.m
//  TestApp2
//
//  Created by Derek Clarkson on 7/23/11.
//  Copyright 2011 Sensis. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TestApp2AppDelegate.h"
#import "SISimon.h"

int main(int argc, char *argv[]) {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//@autoreleasepool {
	
	SIRun();
	
	int retVal =  UIApplicationMain(argc, argv, nil, NSStringFromClass([TestApp2AppDelegate class]));
	[pool release];
	return retVal;
}
