//
//  SIActionFactory.m
//  Simon
//
//  Created by Derek Clarkson on 8/08/11.
//  Copyright 2011. All rights reserved.
//

#import "SIUIHandlerFactory.h"
#import <dUsefulStuff/DCCommon.h>

@implementation SIUIHandlerFactory

// Static instance of the factory.
static SIUIHandlerFactory *factory;

+(void) setHandlerFactory:(SIUIHandlerFactory *) handlerFactory {
	DC_DEALLOC(factory);
	factory = [handlerFactory retain];
}

+(SIUIHandlerFactory *) handlerFactory {
	if (factory == nil) {
		factory = [[SIUIHandlerFactory alloc] init];
	}
	return factory;
}

-(SIUIViewHandler *) createHandlerForView:(UIView<DNNode> *) view {
	SIUIViewHandler *handler = [[[SIUIViewHandler alloc] init] autorelease];	
	handler.view = view;
	return handler;
}

@end
