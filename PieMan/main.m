//
//  main.m
//  PieMan
//
//  Created by Derek Clarkson on 2/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Simon-core-OSX/SIStory.h>

// Function declarations.
int arguments(const char * argv[]);



int main(int argc, const char * argv[])
{

	int retCode = arguments(argv);
	
	@autoreleasepool {
	    
	    // insert code here...
	    NSLog(@"Hello, World!");
	    
	}
	return retCode;
}

int arguments(const char * argv[]) {
	return 0;
}
