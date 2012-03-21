//
//  SIActionFactory.m
//  Simon
//
//  Created by Derek Clarkson on 8/08/11.
//  Copyright 2011. All rights reserved.
//

#import "SIUIViewHandlerFactory.h"
#import <dUsefulStuff/DCCommon.h>
#import "SIUIButtonHandler.h"
#import "SIUILabelHandler.h"

@implementation SIUIViewHandlerFactory

-(SIUIViewHandler *) handlerForView:(UIView<DNNode> *) view {
	
	// get the correct handler.
	SIUIViewHandler *handler = nil;
	if ([view isKindOfClass:[UIButton class]]) {
		handler = [[[SIUIButtonHandler alloc] init] autorelease];
	} else if ([view isKindOfClass:[UILabel class]]) {
		handler = [[[SIUILabelHandler alloc] init] autorelease];
	} else {
		handler = [[[SIUIViewHandler alloc] init] autorelease];
	}

	// Set properties and return.
   handler.view = view;
	return handler;
}

@end
