//
//  main.m
//  PieMan
//
//  Created by Derek Clarkson on 2/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Simon/SIStory.h>
#import "PIPieMan.h"

// Function declarations.
int arguments(const char * argv[]);

int main(int argc, const char * argv[]) {

	int retCode = arguments(argv);
	
	@autoreleasepool {
		PIPieMan *pieman = [[[PIPieMan alloc] init] autorelease];
		[pieman start];
		
		NSRunLoop *theRL = [NSRunLoop currentRunLoop];
		while (!pieman.finished && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
		
	}
	return retCode;
}

int arguments(const char * argv[]) {
	return 0;
}
