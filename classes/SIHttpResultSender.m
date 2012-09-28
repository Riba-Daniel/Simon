//
//  SIHttpResultSender.m
//  Simon
//
//  Created by Derek Clarkson on 9/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Simon/SIHttpResultSender.h>
#import <dUsefulStuff/DCCommon.h>

@interface SIHttpResultSender () {
	@private
	SIHttpConnection *_connection;
}

@end

@implementation SIHttpResultSender

-(void) dealloc {
	DC_DEALLOC(_connection);
	[super dealloc];
}

-(id) initWithConnection:(SIHttpConnection *) connection {
	self = [super init];
	if (self) {
		_connection = [connection retain];
	}
	return self;
	
}

-(void) runStarting:(NSNotification *) notification {
	[super runStarting:notification];
	// DO something http'y
}

-(void) storyStarting:(NSNotification *) notification {
	[super storyStarting:notification];
	// DO something http'y
}

-(void) storyExecuted:(NSNotification *) notification {
	[super storyExecuted:notification];
	// DO something http'y
}

-(void) runFinished:(NSNotification *) notification {
	[super runFinished:notification];
	// DO something http'y
}

@end
