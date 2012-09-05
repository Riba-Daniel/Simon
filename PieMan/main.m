//
//  main.m
//  PieMan
//
//  Created by Derek Clarkson on 2/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIStory.h>
#import "PIPieman.h"

// Function declarations.
int arguments(const char * argv[]);

int main(int argc, const char * argv[]) {

	int retCode = arguments(argv);
	
	@autoreleasepool {
		
		// Get the path to the app.
		NSString *appPath = [NSString stringWithUTF8String:argv[1]];
		NSLog(@"Launching simulator with app at path %@", appPath);
		
		PIPieman *pieman = [[[PIPieman alloc] init] autorelease];
		pieman.appPath = appPath;
		[pieman start];
		
#ifdef DC_DEBUG
		NSLog(@"Initialing run loop execution cycle");
#endif
		NSRunLoop *theRL = [NSRunLoop currentRunLoop];
		while (!pieman.finished && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
#ifdef DC_DEBUG
		NSLog(@"Run loop cycle ended. Exiting Pieman.");
#endif
	}
	return retCode;
}

int arguments(const char * argv[]) {
	return 0;
}
