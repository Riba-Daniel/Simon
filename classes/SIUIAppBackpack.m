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

-(void) startUp:(NSNotification *) notification {
	[super startUp:notification];
	if(![SIAppBackpack isArgumentPresentWithName:ARG_AUTORUN]) {
		[ui displayUI];
	}
}

-(void) runFinished:(NSNotification *) notification {
	[super runFinished:notification];
	[ui displayUI];
}

@end
