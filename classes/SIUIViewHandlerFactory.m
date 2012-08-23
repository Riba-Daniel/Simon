//
//  SIActionFactory.m
//  Simon
//
//  Created by Derek Clarkson on 8/08/11.
//  Copyright 2011. All rights reserved.
//

#import <Simon/SIUIViewHandlerFactory.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIUIButtonHandler.h>
#import <Simon/SIUILabelHandler.h>

@implementation SIUIViewHandlerFactory

-(SIUIViewHandler *) handlerForView:(UIView<DNNode> *) view {
	
	// get the correct handler.
	SIUIViewHandler *handler = nil;
	if ([view isKindOfClass:[UIButton class]]) {
		handler = [[SIUIButtonHandler alloc] init];
	} else if ([view isKindOfClass:[UILabel class]]) {
		handler = [[SIUILabelHandler alloc] init];
	} else {
		handler = [[SIUIViewHandler alloc] init];
	}

	// Set properties and return.
   handler.view = view;
	return [handler autorelease];
}

@end
