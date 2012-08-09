//
//  SIUIAppBackpack.m
//  Simon
//
//  Created by Derek Clarkson on 9/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIUIAppBackpack.h"
#import <dUsefulStuff/DCCommon.h>

@interface SIUIAppBackpack ()
-(void) windowRemoved:(NSNotification *) notification;
@end

@implementation SIUIAppBackpack

-(void) dealloc {
	DC_LOG(@"Freeing memory and exiting");
	DC_DEALLOC(ui);
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(windowRemoved:)
																	name:SI_WINDOW_REMOVED_NOTIFICATION
																 object:nil];
		ui = [[SIUIReportManager alloc] init];
	}
	return self;
}

-(void) startUp:(NSNotification *) notification {
	[super startUp:notification];
	[self executeOnSimonThread: ^{
		if([SIAppBackpack isArgumentPresentWithName:ARG_NO_AUTORUN]) {
			[ui displayUI];
		} else {
			self.state.filteredSources = nil;
			[self.runner run];
		}
	}];
}

-(void) shutDown:(NSNotification *) notification {
	[super shutDown:notification];
	[ui removeWindow];
}

-(void) runFinished:(NSNotification *) notification {
	[super runFinished:notification];
	[ui displayUI];
}

-(void) runStories:(NSNotification *) notification {
	// Override and remove window first.
	[ui removeWindow];
}

-(void) windowRemoved:(NSNotification *) notification {
	DC_LOG(@"UI Removed");
	[self executeOnSimonThread: ^{
		[self.runner run];
	}];
}


@end
