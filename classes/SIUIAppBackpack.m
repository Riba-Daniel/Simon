//
//  SIUIAppBackpack.m
//  Simon
//
//  Created by Derek Clarkson on 9/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Simon/SIUIAppBackpack.h>
#import <Simon/NSObject+Simon.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/NSProcessInfo+Simon.h>
#import <dUsefulStuff/DCDialogs.h>

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

-(void) startUpFinished {
	// Everything is loaded and ready to go so post a notification to run or display the UI.
	if ([[NSProcessInfo processInfo] isArgumentPresentWithName:ARG_AUTORUN]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:SI_RUN_STORIES_NOTIFICATION object:self];
	} else {
		[ui displayUI];
	}
}

-(void) shutDown:(NSNotification *) notification  {
	[super shutDown:notification];
	[self executeBlockOnMainThread:^() {
		NSDictionary *userinfo = notification.userInfo;
		if ([(NSNumber *)userinfo[SI_NOTIFICATION_KEY_STATUS] intValue] > 0) {
			[DCDialogs displayMessage:userinfo[SI_NOTIFICATION_KEY_MESSAGE] title:@"Error"];
		}
	}];
}

-(void) runFinished:(NSNotification *) notification {
	[super runFinished:notification];
	[ui displayUI];
}

@end
