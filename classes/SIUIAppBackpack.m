//
//  SIUIAppBackpack.m
//  Simon
//
//  Created by Derek Clarkson on 9/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIUIAppBackpack.h"
#import <dUsefulStuff/DCCommon.h>

@implementation SIUIAppBackpack

-(void) dealloc {
	DC_LOG(@"Freeing memory and exiting");
	DC_DEALLOC(ui);
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self) {
		// Load the display manager.
		ui = [[SIUIReportManager alloc] init];
	}
	return self;
}

-(void) runFinished:(NSNotification *) notification {
	[super runFinished:notification];
	[ui displayUI];
}

-(void) runStories:(NSNotification *) notification {
	// Override to show ui if necessary when starting up.
	[self executeOnSimonThread: ^{
		// If the notification originated from self and we are not autorunning, then it's startup so go straight to the ui.
		if(notification.object == self && ![SIAppBackpack isArgumentPresentWithName:ARG_AUTORUN]) {
			[ui displayUI];
		} else {
			[self.runner run];
		}
	}];
}

@end
